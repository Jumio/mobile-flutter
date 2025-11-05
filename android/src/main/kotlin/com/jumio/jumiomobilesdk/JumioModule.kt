package com.jumio.jumiomobilesdk

import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import com.jumio.defaultui.JumioActivity
import com.jumio.sdk.credentials.JumioCredentialCategory.FACE
import com.jumio.sdk.credentials.JumioCredentialCategory.ID
import com.jumio.sdk.enums.JumioDataCenter
import com.jumio.sdk.preload.JumioPreloadCallback
import com.jumio.sdk.preload.JumioPreloader
import com.jumio.sdk.result.JumioResult
import io.flutter.embedding.android.FlutterEngineProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class JumioModule : ModuleBase(), JumioPreloadCallback {
    companion object {
        private const val REQUEST_CODE = 101
    }

    private var channel: MethodChannel? = null
    private var authorizationToken: String? = null
    private var dataCenter: String? = null

    init {
        onHostActivitySet = {
            (hostActivity as FlutterEngineProvider).provideFlutterEngine(hostActivity)?.let {
                channel = MethodChannel(it.dartExecutor, "com.jumio.fluttersdk")
            }
        }
    }

    private var preloaderFinishedCallback: (() -> Unit)? = null

    override val methods: Map<String, (MethodCall) -> Unit> = mapOf(
        "init" to { call ->
            this.authorizationToken = call.argument("authorizationToken")
            this.dataCenter = call.argument("dataCenter")
            init(this.authorizationToken ?: "", this.dataCenter ?: "")
        },
        "start" to { _ ->
            if (!checkAndSendCachedResult()) {
                start()
            }
        },
        "getCachedResult" to { _ ->
            if (!checkAndSendCachedResult()) {
                sendResult(null)
            }
        },
        "setPreloaderFinishedBlock" to { _ -> setPreloaderFinishedBlock() },
        "preloadIfNeeded" to { _ -> preloadIfNeeded() }
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
            else -> {
                sendResult(null)
            }
        }
    }

    private fun initSdk() {
        val token = this.authorizationToken
        val dataCenter = this.dataCenter

        if (token == null || dataCenter == null) {
            showErrorMessage("SDK not initialized. Please call init() first.")
            return
        }

        try {
            val intent = Intent(hostActivity, JumioActivity::class.java).apply {
                putExtra(JumioActivity.EXTRA_TOKEN, token)
                putExtra(JumioActivity.EXTRA_DATACENTER, dataCenter)
                putExtra(JumioActivity.EXTRA_CUSTOM_THEME, R.style.AppThemeCustomJumio)
            }
            hostActivity.startActivityForResult(intent, REQUEST_CODE)
        } catch (e: Exception) {
            showErrorMessage("Error starting the Jumio SDK: " + e.localizedMessage)
        }
    }

    private fun start() {
        ensurePermissionsAndRun(
            onGranted = {
                initSdk()
            },
            onDenied = {
                showErrorMessage("Camera permissions are required to continue.", "PERMISSIONS_DENIED")
            }
        )
    }

    private fun checkAndSendCachedResult(): Boolean {
        JumioMobileSdkPlugin.pendingResult?.let {
            sendResult(it)
            JumioMobileSdkPlugin.pendingResult = null
            JumioMobileSdkPlugin.pendingError = null
            return true
        }
        JumioMobileSdkPlugin.pendingError?.let {
            sendResult(it)
            JumioMobileSdkPlugin.pendingResult = null
            JumioMobileSdkPlugin.pendingError = null
            return true
        }
        return false
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
        if (!sendResult(result)) {
            JumioMobileSdkPlugin.pendingResult = result
            JumioMobileSdkPlugin.pendingError = null
        }
    }

    private fun sendCancelResult(jumioResult: JumioResult?) {
        val errorMap: Map<String, Any?>
        if (jumioResult?.error != null) {
            val errorMessage = jumioResult.error?.message ?: ""
            val errorCode = jumioResult.error?.code ?: ""
            errorMap = mapOf(
                "errorCode" to errorCode,
                "errorMessage" to errorMessage
            )
        } else {
            errorMap = mapOf(
                "errorCode" to "000000",
                "errorMessage" to "There was a problem extracting the scan result"
            )
        }

        if (!sendResult(errorMap)) {
            JumioMobileSdkPlugin.pendingError = errorMap
            JumioMobileSdkPlugin.pendingResult = null
        }
    }

    private fun getJumioDataCenter(dataCenter: String) = try {
        JumioDataCenter.valueOf(dataCenter)
    } catch (e: IllegalArgumentException) {
        null
    }

    private fun setPreloaderFinishedBlock() {
        with(JumioPreloader) {
            init(hostActivity)
            setCallback(this@JumioModule)
        }
        preloaderFinishedCallback = {
            Handler(Looper.getMainLooper()).post {
                channel?.invokeMethod("preloadFinished", null)
            }
        }
    }

    private fun preloadIfNeeded() {
        with(JumioPreloader) {
            preloadIfNeeded()
        }
    }

    override fun preloadFinished() {
        preloaderFinishedCallback?.invoke()
    }
}