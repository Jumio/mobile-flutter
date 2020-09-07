package com.jumio.jumiomobilesdk

import android.app.Activity
import android.content.Intent
import android.util.Log
import com.jumio.bam.BamCardInformation
import com.jumio.bam.BamSDK
import com.jumio.bam.BamSDK.EXTRA_ERROR_CODE
import com.jumio.bam.BamSDK.EXTRA_ERROR_MESSAGE
import com.jumio.bam.enums.CreditCardType
import com.jumio.bam.enums.CreditCardType.*
import com.jumio.core.enums.JumioCameraPosition
import com.jumio.core.enums.JumioDataCenter
import com.jumio.jumiomobilesdk.PermissionRequestCode.BAM
import io.flutter.plugin.common.MethodCall
import java.util.*
import java.lang.*
import kotlin.collections.ArrayList

class BamCheckoutModule : ModuleBase() {

    companion object {
        private val TAG = BamCheckoutModule::class.java.name
    }

    private var bamSDK: BamSDK? = null

    @Suppress("RedundantLambdaArrow")
    override val methods: Map<String, (MethodCall) -> Unit> = mapOf(
            "initBAM" to { call ->
                initBAM(
                        call.argument("apiToken") ?: "",
                        call.argument("apiSecret") ?: "",
                        call.argument("dataCenter") ?: "",
                        call.argument("options"))
            },
            "startBAM" to { _ -> startBAM() }
    )

    private fun initBAM(apiToken: String, apiSecret: String, dataCenter: String, options: Map<String, Any?>?) {
        if (!BamSDK.isSupportedPlatform(hostActivity)) {
            showErrorMessage("This platform is not supported.")
        } else if (apiToken.isEmpty() || apiSecret.isEmpty() || dataCenter.isEmpty()) {
            showErrorMessage("Missing required parameters apiToken, apiSecret or dataCenter.")
        } else {
            initializeSDK(dataCenter, apiToken, apiSecret, options)
        }
    }

    private fun initializeSDK(dataCenter: String, apiToken: String, apiSecret: String, options: Map<String, Any?>?) {
        try {
            val center: JumioDataCenter? = try {
                JumioDataCenter.valueOf(dataCenter.toUpperCase(Locale.ROOT))
            } catch (e: Exception) {
                throw Exception("DataCenter not valid: $dataCenter")
            }
            val sdk = BamSDK.create(hostActivity, apiToken, apiSecret, center)
            bamSDK = sdk
            configureBAM(sdk, options?.withLowercaseKeys() ?: emptyMap())
            sendResult(null)
        } catch (e: Exception) {
            showErrorMessage("Error initializing the BAM SDK: ${e.localizedMessage}")
        }
    }

    private fun configureBAM(sdk: BamSDK, options: Map<String, Any?>) {
        (options["cardholdernamerequired"] as? Boolean)?.let { sdk.setCardHolderNameRequired(it) }
        (options["sortcodeandaccountnumberrequired"] as? Boolean)?.let { sdk.setSortCodeAndAccountNumberRequired(it) }
        (options["expiryrequired"] as? Boolean)?.let { sdk.setExpiryRequired(it) }
        (options["cvvrequired"] as? Boolean)?.let { sdk.setCvvRequired(it) }
        (options["expiryeditable"] as? Boolean)?.let { sdk.setExpiryEditable(it) }
        (options["cardholdernameeditable"] as? Boolean)?.let { sdk.setCardHolderNameEditable(it) }
        (options["reportingcriteria"] as? String)?.let { sdk.setMerchantReportingCriteria(it) }
        (options["vibrationeffectenabled"] as? Boolean)?.let { sdk.setVibrationEffectEnabled(it) }
        (options["enableflashonscanstart"] as? Boolean)?.let { sdk.setEnableFlashOnScanStart(it) }
        (options["cardnumbermaskingenabled"] as? Boolean)?.let { sdk.setCardNumberMaskingEnabled(it) }
        (options["cameraposition"] as? String)?.let {
            val cameraPosition = if (it.toLowerCase(Locale.ROOT) == "front") {
                JumioCameraPosition.FRONT
            } else {
                JumioCameraPosition.BACK
            }
            sdk.setCameraPosition(cameraPosition)
        }
        (options["cardtypes"] as? List<*>)?.let { list ->
            val creditCardTypes = list.map {
                when ((it as? String)?.toLowerCase(Locale.ROOT)) {
                    "visa" -> VISA
                    "master_card" -> MASTER_CARD
                    "american_express" -> AMERICAN_EXPRESS
                    "china_unionpay" -> CHINA_UNIONPAY
                    "diners_club" -> DINERS_CLUB
                    "discover" -> DISCOVER
                    "jcb" -> JCB
                    else -> null
                }
            }.filterNotNull()

            sdk.setSupportedCreditCardTypes(ArrayList(creditCardTypes))
        }
    }

    private fun startBAM() {
        bamSDK?.let {
            try {
                ensurePermissionsAndRun(BAM) { it.start() }
            } catch (e: Exception) {
                Log.w(TAG, "Exception encountered while starting Authentication SDK: ${e.message}")
                showErrorMessage("Error starting the BAM SDK: " + e.localizedMessage)
            }
        } ?: showErrorMessage("BAM SDK must be initialized before starting.")
    }

    override fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == BamSDK.REQUEST_CODE && data != null) {
            val scanReferenceList = data.getStringArrayListExtra(BamSDK.EXTRA_SCAN_ATTEMPTS)
                    ?: ArrayList<String>()

            if (resultCode == Activity.RESULT_OK) {
                sendScanResult(data, scanReferenceList)
            } else if (resultCode == Activity.RESULT_CANCELED) {
                sendCancelResult(data, scanReferenceList)
            }
            return true
        }
        return false
    }

    private fun sendScanResult(data: Intent, scanReferenceList: ArrayList<String>) {
        val cardInformation = data.getParcelableExtra(BamSDK.EXTRA_CARD_INFORMATION) as? BamCardInformation

        cardInformation?.let {
            val result = mapOf<String, Any?>(
                    "cardType" to when (it.getCardType()) {
                        VISA -> "VISA"
                        MASTER_CARD -> "MASTER_CARD"
                        AMERICAN_EXPRESS -> "AMERICAN_EXPRESS"
                        CHINA_UNIONPAY -> "CHINA_UNIONPAY"
                        DINERS_CLUB -> "DINERS_CLUB"
                        DISCOVER -> "DISCOVER"
                        JCB -> "JCB"
                        else -> null
                    },
                    "cardNumber" to java.lang.String.valueOf(it.getCardNumber()),
                    "cardNumberGrouped" to java.lang.String.valueOf(it.getCardNumberGrouped()),
                    "cardNumberMasked" to java.lang.String.valueOf(it.getCardNumberMasked()),
                    "cardExpiryMonth" to java.lang.String.valueOf(it.getCardExpiryDateMonth()),
                    "cardExpiryYear" to java.lang.String.valueOf(it.getCardExpiryDateYear()),
                    "cardExpiryDate" to java.lang.String.valueOf(it.getCardExpiryDate()),
                    "cardCVV" to java.lang.String.valueOf(it.getCardCvvCode()),
                    "cardHolderName" to java.lang.String.valueOf(it.getCardHolderName()),
                    "cardSortCode" to java.lang.String.valueOf(it.getCardSortCode()),
                    "cardAccountNumber" to java.lang.String.valueOf(it.getCardAccountNumber()),
                    "cardSortCodeValid" to java.lang.String.valueOf(it.isCardSortCodeValid()),
                    "cardAccountNumberValid" to java.lang.String.valueOf(it.isCardAccountNumberValid())
            ).compact()

            sendResult(result)
        }
    }

    private fun sendCancelResult(data: Intent, scanReferenceList: ArrayList<String>) {
        val errorMessage: String = data.getStringExtra(EXTRA_ERROR_MESSAGE)
        val errorCode: String = data.getStringExtra(EXTRA_ERROR_CODE)

        sendResult(mapOf<String, Any>(
                "errorCode" to errorCode,
                "errorMessage" to errorMessage,
                "scanReferenceList" to scanReferenceList
        ))
    }
}