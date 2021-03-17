package com.jumio.jumiomobilesdk

import android.app.Activity
import android.app.Activity.RESULT_CANCELED
import android.content.Intent
import com.jumio.core.enums.JumioCameraPosition.BACK
import com.jumio.core.enums.JumioCameraPosition.FRONT
import com.jumio.core.enums.JumioDataCenter
import com.jumio.dv.DocumentVerificationSDK
import com.jumio.jumiomobilesdk.PermissionRequestCode.DOCUMENT_VERIFICATION
import io.flutter.plugin.common.MethodCall
import java.util.*

class DocumentVerificationModule : ModuleBase() {
    @Suppress("RedundantLambdaArrow")
    override val methods: Map<String, (MethodCall) -> Unit> = mapOf(
            "initDocumentVerification" to { call ->
                initDocumentVerification(
                        call.argument("apiToken") ?: "",
                        call.argument("apiSecret") ?: "",
                        call.argument("dataCenter") ?: "",
                        call.argument("options"))
            },
            "startDocumentVerification" to { _ -> startDocumentVerification() }
    )

    private var documentVerificationSDK: DocumentVerificationSDK? = null

    private fun initDocumentVerification(apiToken: String, apiSecret: String, dataCenter: String, options: Map<String, Any?>?) {
        if (apiToken.isNotEmpty() && apiSecret.isNotEmpty() && dataCenter.isNotEmpty()) {
            val center = try {
                JumioDataCenter.valueOf(dataCenter.toUpperCase(Locale.ROOT))
            } catch (e: Exception) {
                throw Exception("Datacenter not valid: $dataCenter")
            }
            if (this.documentVerificationSDK != null) {
                //SDK isn't null because it's already initialized or still being cleaned up
                return
            }
            try {
                val sdk = DocumentVerificationSDK.create(hostActivity, apiToken, apiSecret, center)
                documentVerificationSDK = sdk
                configureSdk(sdk, options?.withLowercaseKeys() ?: emptyMap())
                sendResult(null)
            } catch (e: Exception) {
                showErrorMessage("Error initializing the Document Verification SDK: " + e.localizedMessage)
            }
        } else {
            showErrorMessage("Missing required parameters apiToken, apiSecret or dataCenter.")
        }
    }

    private fun configureSdk(sdk: DocumentVerificationSDK, options: Map<String, Any?>) {
        (options["type"] as? String)?.let { sdk.setType(it) }
        (options["customdocumentcode"] as? String)?.let { sdk.setCustomDocumentCode(it) }
        (options["country"] as? String)?.let { sdk.setCountry(it) }
        (options["reportingcriteria"] as? String)?.let { sdk.setReportingCriteria(it) }
        (options["callbackurl"] as? String)?.let { sdk.setCallbackUrl(it) }
        (options["enableextraction"] as? Boolean)?.let {
            sdk.setEnableExtraction(it as? Boolean ?: false)
        }
        (options["customerinternalreference"] as? String)?.let { sdk.setCustomerInternalReference(it) }
        (options["userreference"] as? String)?.let { sdk.setUserReference(it) }
        (options["documentname"] as? String)?.let { sdk.setDocumentName(it) }
        (options["cameraposition"] as? String)?.let {
            val cameraPosition = if (it.toLowerCase(Locale.ROOT) == "front") FRONT else BACK
            sdk.setCameraPosition(cameraPosition)
        }
    }

    private fun startDocumentVerification() {
        documentVerificationSDK?.let {
            try {
                ensurePermissionsAndRun(DOCUMENT_VERIFICATION) { it.start() }
            } catch (e: Exception) {
                showErrorMessage("Error starting the Netverify SDK: " + e.localizedMessage)
            }
        }
                ?: showErrorMessage("The Netverify SDK is not initialized yet. Call initNetverify() first.")
    }

    override fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == DocumentVerificationSDK.REQUEST_CODE) {
            if (data != null) {
                val scanReference = data.getStringExtra(DocumentVerificationSDK.EXTRA_SCAN_REFERENCE) ?: ""

                if (resultCode == Activity.RESULT_OK) {
                    val result = mapOf("scanReference" to scanReference)
                    sendResult(result)
                } else if (resultCode == RESULT_CANCELED) {
                    val errorMessage: String = data.getStringExtra(DocumentVerificationSDK.EXTRA_ERROR_MESSAGE) ?: ""
                    val errorCode: String = data.getStringExtra(DocumentVerificationSDK.EXTRA_ERROR_CODE) ?: ""
                    sendResult(mapOf<String, String>(
                            "errorCode" to errorCode,
                            "errorMessage" to errorMessage,
                            "scanReference" to scanReference
                    ))
                }
            }
            if (documentVerificationSDK != null) {
                documentVerificationSDK?.destroy()
                documentVerificationSDK = null
            }
            return true
        } else {
            return false
        }
    }
}