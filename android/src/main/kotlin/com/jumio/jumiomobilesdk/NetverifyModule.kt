package com.jumio.jumiomobilesdk

import android.app.Activity
import android.app.Activity.RESULT_CANCELED
import android.content.Intent
import com.jumio.core.enums.JumioCameraPosition.BACK
import com.jumio.core.enums.JumioCameraPosition.FRONT
import com.jumio.core.enums.JumioDataCenter
import com.jumio.jumiomobilesdk.PermissionRequestCode.NETVERIFY
import com.jumio.nv.NetverifyDocumentData
import com.jumio.nv.NetverifySDK
import com.jumio.nv.NetverifySDK.EXTRA_ERROR_CODE
import com.jumio.nv.NetverifySDK.EXTRA_ERROR_MESSAGE
import com.jumio.nv.data.document.NVDocumentType
import com.jumio.nv.data.document.NVDocumentVariant.PAPER
import com.jumio.nv.data.document.NVDocumentVariant.PLASTIC
import com.jumio.nv.data.document.NVMRZFormat
import com.jumio.nv.enums.NVExtractionMethod
import com.jumio.nv.enums.NVGender
import com.jumio.nv.enums.NVWatchlistScreening
import com.jumio.nv.NetverifyDeallocationCallback
import io.flutter.plugin.common.MethodCall
import java.util.*
import kotlin.collections.ArrayList

class NetverifyModule : ModuleBase(), NetverifyDeallocationCallback {
    @Suppress("RedundantLambdaArrow")
    override val methods: Map<String, (MethodCall) -> Unit> = mapOf(
            "initNetverify" to { call ->
                initNetverify(
                        call.argument("apiToken") ?: "",
                        call.argument("apiSecret") ?: "",
                        call.argument("dataCenter") ?: "",
                        call.argument("options"))
            },
            "startNetverify" to { _ -> startNetverify() },
            "enableEMRTD" to { _ -> enableEMRTD() }
    )

    private var netverifySDK: NetverifySDK? = null

    private fun initNetverify(apiToken: String, apiSecret: String, dataCenter: String, options: Map<String, Any>?) {
        if (apiToken.isEmpty() || apiSecret.isEmpty() || dataCenter.isEmpty()) {
            showErrorMessage("Missing required parameters apiToken, apiSecret or dataCenter.")
        } else if (this.netverifySDK != null) {
            //SDK isn't null because it's already initialized or still being cleaned up
            return
        } else {
            try {
                initSdk(dataCenter, apiToken, apiSecret, options)
            } catch (e: Exception) {
                showErrorMessage("Error initializing the Netverify SDK: " + e.localizedMessage)
            }
        }
    }

    private fun initSdk(dataCenter: String, apiToken: String, apiSecret: String, options: Map<String, Any>?) {
        val center = try {
            JumioDataCenter.valueOf(dataCenter.toUpperCase(Locale.ROOT))
        } catch (e: Exception) {
            throw Exception("DataCenter not valid: $dataCenter")
        }
        val netverifySDK = NetverifySDK.create(hostActivity, apiToken, apiSecret, center)
        options?.let { configureNetverify(netverifySDK, it.withLowercaseKeys()) }
        this.netverifySDK = netverifySDK
        sendResult(null)
    }

    private fun configureNetverify(netverifySDK: NetverifySDK, options: Map<String, Any>) {
        (options["enableverification"] as? Boolean)?.let { netverifySDK.setEnableVerification(it) }
        (options["callbackurl"] as? String)?.let { netverifySDK.setCallbackUrl(it) }
        (options["enableidentityverification"] as? Boolean)?.let { netverifySDK.setEnableIdentityVerification(it) }
        (options["preselectedcountry"] as? String)?.let { netverifySDK.setPreselectedCountry(it) }
        (options["customerinternalreference"] as? String)?.let { netverifySDK.setCustomerInternalReference(it) }
        (options["reportingcriteria"] as? String)?.let { netverifySDK.setReportingCriteria(it) }
        (options["userreference"] as? String)?.let { netverifySDK.setUserReference(it) }
        (options["enableepassport"] as? Boolean)?.let { netverifySDK.setEnableEMRTD(it) }

        (options["watchlistsearchprofile"] as? String)?.let { netverifySDK.setWatchlistSearchProfile(it) }
        (options["senddebuginfotojumio"] as? Boolean)?.let { netverifySDK.sendDebugInfoToJumio(it) }
        (options["dataextractiononmobileonly"] as? Boolean)?.let { netverifySDK.setDataExtractionOnMobileOnly(it) }
        (options["cameraposition"] as? String)?.let { netverifySDK.setCameraPosition(if (it.toLowerCase(Locale.ROOT) == "front") FRONT else BACK) }
        (options["preselecteddocumentvariant"] as? String)?.let { netverifySDK.setPreselectedDocumentVariant(if (it.toLowerCase(Locale.ROOT) == "paper") PAPER else PLASTIC) }

        (options["enablewatchlistscreening"] as? String)?.let {
            netverifySDK.setWatchlistScreening(when (it.toLowerCase(Locale.ROOT)) {
                "enabled" -> NVWatchlistScreening.ENABLED
                "disabled" -> NVWatchlistScreening.DISABLED
                else -> NVWatchlistScreening.DEFAULT
            })
        }
        (options["documenttypes"] as? List<*>)?.let {
            netverifySDK.setPreselectedDocumentTypes(
                    it.mapNotNull { rawType ->
                        when ((rawType as? String)?.toLowerCase(Locale.ROOT)) {
                            "passport" -> NVDocumentType.PASSPORT
                            "driver_license" -> NVDocumentType.DRIVER_LICENSE
                            "identity_card" -> NVDocumentType.IDENTITY_CARD
                            "visa" -> NVDocumentType.VISA
                            else -> null
                        }
                    }.let { documentTypes -> ArrayList(documentTypes) })
        }
    }

    private fun startNetverify() {
        netverifySDK?.let {
            try {
                ensurePermissionsAndRun(NETVERIFY) { it.start() }
            } catch (e: Exception) {
                showErrorMessage("Error starting the Netverify SDK: " + e.localizedMessage)
            }
        }
                ?: showErrorMessage("The Netverify SDK is not initialized yet. Call initNetverify() first.")
    }

    override fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return if (requestCode == NetverifySDK.REQUEST_CODE) {
            if (data != null) {
                val scanReference = data.getStringExtra(NetverifySDK.EXTRA_SCAN_REFERENCE) ?: ""
                if (resultCode == Activity.RESULT_OK) {
                    sendScanResult(data, scanReference)
                } else if (resultCode == RESULT_CANCELED) {
                    sendCancelResult(data, scanReference)
                }
            }
            if(netverifySDK != null) {
                netverifySDK?.destroy()
                netverifySDK?.checkDeallocation(this)
            }
            true
        } else {
            false
        }
    }

    private fun sendScanResult(data: Intent, scanReference: String) {
        val documentData = data.getParcelableExtra(NetverifySDK.EXTRA_SCAN_DATA) as? NetverifyDocumentData

        documentData?.let {
            val result = mapOf(
                    "selectedCountry" to documentData.getSelectedCountry(),
                    "selectedDocumentType" to when (it.getSelectedDocumentType()) {
                        NVDocumentType.PASSPORT -> "PASSPORT"
                        NVDocumentType.DRIVER_LICENSE -> "DRIVER_LICENSE"
                        NVDocumentType.IDENTITY_CARD -> "IDENTITY_CARD"
                        NVDocumentType.VISA -> "VISA"
                        else -> null
                    },
                    "idNumber" to it.getIdNumber(),
                    "personalNumber" to it.getPersonalNumber(),
                    "issuingDate" to (it.getIssuingDate()?.iso8601String ?: ""),
                    "expiryDate" to (it.getExpiryDate()?.iso8601String ?: ""),
                    "issuingCountry" to it.getIssuingCountry(),
                    "lastName" to it.getLastName(),
                    "firstName" to it.getFirstName(),
                    "dob" to (it.getDob()?.iso8601String ?: ""),
                    "gender" to when (it.getGender()) {
                        NVGender.M -> "m"
                        NVGender.F -> "f"
                        NVGender.X -> "x"
                        else -> null
                    },
                    "originatingCountry" to it.getOriginatingCountry(),
                    "addressLine" to it.getAddressLine(),
                    "city" to it.getCity(),
                    "subdivision" to it.getSubdivision(),
                    "postCode" to it.getPostCode(),
                    "optionalData1" to it.optionalData1,
                    "optionalData2" to it.optionalData2,
                    "placeOfBirth" to it.getPlaceOfBirth(),
                    "extractionMethod" to when (it.getExtractionMethod()) {
                        NVExtractionMethod.MRZ -> "MRZ"
                        NVExtractionMethod.OCR -> "OCR"
                        NVExtractionMethod.BARCODE -> "BARCODE"
                        NVExtractionMethod.BARCODE_OCR -> "BARCODE_OCR"
                        NVExtractionMethod.NONE -> "NONE"
                        else -> null
                    },
                    "scanReference" to scanReference,
                    //MRZ data if available
                    "mrzData" to it.mrzData?.let { mrzData ->
                        mapOf(
                                "format" to when (mrzData.format) {
                                    NVMRZFormat.MRP -> "MRP"
                                    NVMRZFormat.TD1 -> "TD1"
                                    NVMRZFormat.TD2 -> "TD2"
                                    NVMRZFormat.CNIS -> "CNIS"
                                    NVMRZFormat.MRV_A -> "MRVA"
                                    NVMRZFormat.MRV_B -> "MRVB"
                                    NVMRZFormat.Unknown -> "UNKNOWN"
                                    else -> null
                                },
                                "line1" to mrzData.getMrzLine1(),
                                "line2" to mrzData.getMrzLine2(),
                                "line3" to mrzData.getMrzLine3(),
                                "idNumberValid" to mrzData.idNumberValid(),
                                "dobValid" to mrzData.dobValid(),
                                "expiryDateValid" to mrzData.expiryDateValid(),
                                "personalNumberValid" to mrzData.personalNumberValid(),
                                "compositeValid" to mrzData.compositeValid()
                        ).compact()
                    }
            ).compact()

            sendResult(result)
        }
    }

    private fun sendCancelResult(data: Intent, scanReference: String) {
        val errorMessage = data.getStringExtra(EXTRA_ERROR_MESSAGE)
        val errorCode = data.getStringExtra(EXTRA_ERROR_CODE)
        sendResult(mapOf<String, String>(
                "errorCode" to errorCode,
                "errorMessage" to errorMessage,
                "scanReference" to scanReference
        ))
    }

    private fun enableEMRTD() {
        netverifySDK?.setEnableEMRTD(true)
                ?: showErrorMessage("The Netverify SDK is not initialized yet. Call initNetverify() first.")
    }

    override fun onNetverifyDeallocated() {
        netverifySDK = null
    }

}