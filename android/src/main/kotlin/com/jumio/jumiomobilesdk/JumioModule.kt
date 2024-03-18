package com.jumio.jumiomobilesdk

import android.content.Intent
import android.os.Build
import com.jumio.defaultui.JumioActivity
import com.jumio.sdk.credentials.JumioCredentialCategory.FACE
import com.jumio.sdk.credentials.JumioCredentialCategory.ID
import com.jumio.sdk.enums.JumioDataCenter
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
            data?.let {
                val jumioResult = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    it.getSerializableExtra(JumioActivity.EXTRA_RESULT, JumioResult::class.java)
                } else {
                    @Suppress("DEPRECATION")
                    it.getSerializableExtra(JumioActivity.EXTRA_RESULT) as JumioResult?
                }

                if (jumioResult?.isSuccess == true) sendScanResult(jumioResult) else sendCancelResult(jumioResult)
            }
            true
        } else {
            false
        }
    }

    private fun init(authorizationToken: String, dataCenter: String) {
        val jumioDataCenter = getJumioDataCenter(dataCenter)

        when {
            jumioDataCenter == null -> showErrorMessage("Invalid Datacenter value.")
            authorizationToken.isEmpty() -> showErrorMessage("Missing required parameters one-time session authorization token.")
            else ->
                try {
                    initSdk(dataCenter, authorizationToken)
                } catch (e: Exception) {
                    showErrorMessage("Error initializing the Jumio SDK: " + e.localizedMessage)
                }
        }
    }

    private fun initSdk(dataCenter: String, authorizationToken: String) {
        val intent = Intent(hostActivity, JumioActivity::class.java).apply {
            putExtra(JumioActivity.EXTRA_TOKEN, authorizationToken)
            putExtra(JumioActivity.EXTRA_DATACENTER, dataCenter)

            //The following intent extra can be used to customize the Theme of Default UI
            putExtra(JumioActivity.EXTRA_CUSTOM_THEME, R.style.AppThemeCustomJumio)
        }
        hostActivity.startActivityForResult(intent, REQUEST_CODE)

        sendResult(null)
    }

    private fun start() {
        ensurePermissionsAndRun()
    }

    private fun sendScanResult(jumioResult: JumioResult?) {
        val accountId = jumioResult?.accountId
        val credentialInfoList = jumioResult?.credentialInfos
        val workflowId = jumioResult?.workflowExecutionId

        val result = mutableMapOf<String, Any?>(
            "accountId" to accountId,
            "workflowId" to workflowId
        )
        val credentialArray = mutableListOf<MutableMap<String, Any?>>()

        credentialInfoList?.let {
            credentialInfoList.forEach {
                val eventResultMap = mutableMapOf<String, Any?>(
                    "credentialId" to it.id,
                    "credentialCategory" to it.category.toString()
                )

                when (it.category) {
                    ID -> {
                        val idResult = jumioResult.getIDResult(it)

                        idResult?.let {
                            eventResultMap.putAll(
                                mapOf(
                                    "selectedCountry" to idResult.country,
                                    "selectedDocumentType" to idResult.idType,
                                    "selectedDocumentSubType" to idResult.idSubType,
                                    "idNumber" to idResult.documentNumber,
                                    "personalNumber" to idResult.personalNumber,
                                    "issuingDate" to idResult.issuingDate,
                                    "expiryDate" to idResult.expiryDate,
                                    "issuingCountry" to idResult.issuingCountry,
                                    "lastName" to idResult.lastName,
                                    "firstName" to idResult.firstName,
                                    "gender" to idResult.gender,
                                    "nationality" to idResult.nationality,
                                    "dateOfBirth" to idResult.dateOfBirth,
                                    "addressLine" to idResult.address,
                                    "city" to idResult.city,
                                    "subdivision" to idResult.subdivision,
                                    "postCode" to idResult.postalCode,
                                    "placeOfBirth" to idResult.placeOfBirth,
                                    "mrzLine1" to idResult.mrzLine1,
                                    "mrzLine2" to idResult.mrzLine2,
                                    "mrzLine3" to idResult.mrzLine3,
                                ).compact()
                            )
                        }
                    }
                    FACE -> {
                        val faceResult = jumioResult.getFaceResult(it)

                        faceResult?.let {
                            eventResultMap.putAll(
                                mapOf(
                                    "passed" to faceResult.passed.toString(),
                                ).compact()
                            )
                        }
                    }
                    else -> {}
                }

                credentialArray.add(eventResultMap)
            }
            result["credentials"] = credentialArray
        }
        sendResult(result)
    }

    private fun sendCancelResult(jumioResult: JumioResult?) {
        if (jumioResult?.error != null) {
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

    private fun getJumioDataCenter(dataCenter: String) = try {
        JumioDataCenter.valueOf(dataCenter)
    } catch (e: IllegalArgumentException) {
        null
    }
}