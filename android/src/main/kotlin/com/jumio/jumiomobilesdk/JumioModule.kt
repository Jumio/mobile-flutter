package com.jumio.jumiomobilesdk

import android.content.Intent
import com.jumio.defaultui.JumioActivity
import com.jumio.sdk.result.JumioFaceResult
import com.jumio.sdk.result.JumioIDResult
import com.jumio.sdk.result.JumioResult
import io.flutter.plugin.common.MethodCall

class JumioModule : ModuleBase() {

    companion object {
        private const val REQUEST_CODE = 101
    }

    @Suppress("RedundantLambdaArrow")
    override val methods: Map<String, (MethodCall) -> Unit> = mapOf(
        "init" to { call ->
            init(
                call.argument("authorizationToken") ?: "",
                call.argument("dataCenter") ?: ""
            )
        },
        "start" to { _ -> start() },
    )

    override fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return if (requestCode == REQUEST_CODE) {
            if (data != null) {
                val jumioResult =
                    data.getSerializableExtra(JumioActivity.EXTRA_RESULT) as JumioResult

                if (jumioResult.isSuccess) {
                    sendScanResult(jumioResult)
                } else {
                    sendCancelResult(jumioResult)
                }
            }
            true
        } else {
            false
        }
    }

    private fun init(
        authorizationToken: String,
        dataCenter: String,
    ) {
        if (authorizationToken.isEmpty() || dataCenter.isEmpty()) {
            showErrorMessage("Missing required parameters one-time session authorization token, or dataCenter.")
        } else {
            try {
                initSdk(dataCenter, authorizationToken)
            } catch (e: Exception) {
                showErrorMessage("Error initializing the Netverify SDK: " + e.localizedMessage)
            }
        }
    }

    private fun initSdk(
        dataCenter: String,
        authorizationToken: String
    ) {
        val intent = Intent(hostActivity, JumioActivity::class.java).apply {
            putExtra(JumioActivity.EXTRA_TOKEN, authorizationToken)
            putExtra(JumioActivity.EXTRA_DATACENTER, dataCenter)

            //The following intent extra can be used to customize the Theme of Default UI
            //putExtra(JumioActivity.EXTRA_CUSTOM_THEME, R.style.AppThemeCustomJumio)
        }
        hostActivity.startActivityForResult(intent, REQUEST_CODE)

        sendResult(null)
    }

    private fun start() {
        ensurePermissionsAndRun()
    }

    private fun sendScanResult(jumioResult: JumioResult) {
        val accountId = jumioResult.accountId
        val credentialInfoList = jumioResult.credentialInfos

        val result = mutableMapOf<String, Any?>(
            "accountId" to accountId
        )
        val credentialArray = mutableListOf<MutableMap<String, Any?>>()

        credentialInfoList?.let {
            credentialInfoList.forEach {
                val jumioCredentialResult = jumioResult.getResult(it)

                val eventResultMap = mutableMapOf<String, Any?>(
                    "credentialCategory" to it.category.toString(),
                    "credentialId" to it.id,
                )

                if (jumioCredentialResult is JumioIDResult) {
                    eventResultMap.putAll(
                        mapOf(
                            "selectedCountry" to jumioCredentialResult.country,
                            "selectedDocumentType" to jumioCredentialResult.idType,
                            "idNumber" to jumioCredentialResult.documentNumber,
                            "personalNumber" to jumioCredentialResult.personalNumber,
                            "issuingDate" to jumioCredentialResult.issuingDate,
                            "expiryDate" to jumioCredentialResult.expiryDate,
                            "issuingCountry" to jumioCredentialResult.issuingCountry,
                            "lastName" to jumioCredentialResult.lastName,
                            "firstName" to jumioCredentialResult.firstName,
                            "gender" to jumioCredentialResult.gender,
                            "nationality" to jumioCredentialResult.nationality,
                            "dateOfBirth" to jumioCredentialResult.dateOfBirth,
                            "addressLine" to jumioCredentialResult.address,
                            "city" to jumioCredentialResult.city,
                            "subdivision" to jumioCredentialResult.subdivision,
                            "postCode" to jumioCredentialResult.postalCode,
                            "placeOfBirth" to jumioCredentialResult.placeOfBirth,
                            "mrzLine1" to jumioCredentialResult.mrzLine1,
                            "mrzLine2" to jumioCredentialResult.mrzLine2,
                            "mrzLine3" to jumioCredentialResult.mrzLine3,
                        ).compact()
                    )
                } else if (jumioCredentialResult is JumioFaceResult) {
                    eventResultMap.putAll(
                        mapOf(
                            "passed" to jumioCredentialResult.passed.toString(),
                        ).compact()
                    )
                }
                credentialArray.add(eventResultMap)
            }
            result["credentials"] = credentialArray
        }
        sendResult(result)
    }

    private fun sendCancelResult(jumioResult: JumioResult) {
        if (jumioResult.error != null) {
            val errorMessage = jumioResult.error?.message ?: ""
            val errorCode = jumioResult.error?.code ?: ""
            sendResult(
                mapOf(
                    "errorCode" to errorCode,
                    "errorMessage" to errorMessage
                )
            )
        } else {
            sendResult(
                mapOf(
                    "errorCode" to "000000",
                    "errorMessage" to "There was a problem extracting the scan result"
                )
            )
        }
    }
}