package com.jumio.jumiomobilesdk

import android.app.Activity
import android.app.Activity.RESULT_CANCELED
import android.content.Intent
import com.jumio.MobileSDK
import com.jumio.auth.AuthenticationResult
import android.util.Log
import com.jumio.auth.AuthenticationCallback
import com.jumio.auth.AuthenticationSDK
import com.jumio.core.enums.JumioDataCenter
import com.jumio.jumiomobilesdk.PermissionRequestCode.*
import io.flutter.plugin.common.MethodCall
import java.util.*


class AuthenticationModule : ModuleBase() {
	companion object {
		private val TAG = AuthenticationModule::class.java.name
	}

	private var authenticationSDK: AuthenticationSDK? = null

	@Suppress("RedundantLambdaArrow")
	override val methods: Map<String, (MethodCall) -> Unit> = mapOf(
            "initAuthentication" to { call ->
                initAuthentication(
                        call.argument("apiToken") ?: "",
                        call.argument("apiSecret") ?: "",
                        call.argument("dataCenter") ?: "",
                        call.argument("options"))
            },
            "startAuthentication" to { _ -> startAuthentication() }
    )

	private fun initAuthentication(apiToken: String, apiSecret: String, dataCenter: String, options: Map<String, Any?>?) {
		if (!AuthenticationSDK.isSupportedPlatform(hostActivity)) {
			showErrorMessage("Authentication: This platform is not supported.")
			return
		}
		try {
			if (apiToken.isEmpty() || apiSecret.isEmpty() || dataCenter.isEmpty()) {
				showErrorMessage("Missing required parameters apiToken, apiSecret or dataCenter.")
				return
			}
			val center: JumioDataCenter? = try {
				JumioDataCenter.valueOf(dataCenter.toUpperCase(Locale.ROOT))
			} catch (e: Exception) {
				throw Exception("DataCenter not valid: $dataCenter")
			}
			val sdk = AuthenticationSDK.create(hostActivity, apiToken, apiSecret, center)
			authenticationSDK = sdk
			configureSdk(sdk, options?.withLowercaseKeys() ?: emptyMap())
		} catch (e: Exception) {
			showErrorMessage("Error initializing the Authentication SDK: ${e.localizedMessage}")
		}

	}

	private fun configureSdk(sdk: AuthenticationSDK, options: Map<String, Any?>) {
		(options["callbackurl"] as? String)?.let { sdk.setCallbackUrl(it) }
		(options["userreference"] as? String)?.let { sdk.setUserReference(it) }
		val enrollmentTransactionReference = options["enrollmenttransactionreference"] as? String
		val authenticationTransactionReference = options["authenticationtransactionreference"] as? String
		if (enrollmentTransactionReference != null || authenticationTransactionReference != null) {
			if (authenticationTransactionReference != null) {
				sdk.setAuthenticationTransactionReference(authenticationTransactionReference)
			} else {
				sdk.setEnrollmentTransactionReference(enrollmentTransactionReference)
			}
			ensurePermissionsAndRun(AUTHENTICATION) { initializeSdk(sdk) }
		}
	}

	private fun initializeSdk(sdk: AuthenticationSDK) {
		try {
			sdk.initiate(object : AuthenticationCallback {
                override fun onAuthenticationInitiateSuccess() {
	                sendResult(null)
                }

                override fun onAuthenticationInitiateError(errorCode: String?, errorMessage: String?, retryPossible: Boolean) {
                    authenticationSDK = null
                    showErrorMessage(errorMessage ?: "", errorCode)
                }
            })
		} catch (e: Exception) {
			showErrorMessage("Error initializing the Authentication SDK: ${e.localizedMessage}")
		}
	}

	override fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
		return if (requestCode == AuthenticationSDK.REQUEST_CODE && data != null) {
			var transactionReference: String = data.getStringExtra(AuthenticationSDK.EXTRA_TRANSACTION_REFERENCE)
			if (resultCode == Activity.RESULT_OK) {

				val transactionReference: String = data.getStringExtra(AuthenticationSDK.EXTRA_TRANSACTION_REFERENCE)
				val authenticationResult: AuthenticationResult? = data.getSerializableExtra(AuthenticationSDK.EXTRA_SCAN_DATA) as? AuthenticationResult

				authenticationResult?.let {
					val result = mapOf(
                            "transactionReference" to transactionReference,
                            "authenticationResult" to authenticationResult.toString())
					sendResult(result)
				}

			} else if (resultCode == RESULT_CANCELED) {
				sendCancelResult(data)
			}
			true
		} else {
			false
		}
	}

	private fun sendCancelResult(data: Intent) {
		val errorMessage: String = data.getStringExtra(AuthenticationSDK.EXTRA_ERROR_MESSAGE)
		val errorCode: String = data.getStringExtra(AuthenticationSDK.EXTRA_ERROR_CODE)
		sendResult(mapOf<String, String>(
                "errorCode" to errorCode,
                "errorMessage" to errorMessage
        ))
	}

	private fun startAuthentication() {
		authenticationSDK?.let {
			try {
				it.start()
			} catch (e: Exception) {
				sendResult(false)
			}
		} ?: showErrorMessage("Authentication SDK must be initialized before starting.")
	}
}
