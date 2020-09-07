package com.jumio.jumiomobilesdk

import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.*

/**
 * Returns a ISO8601 string representation of this date object
 */
val Date.iso8601String: String
    get() {
        val tz = TimeZone.getTimeZone("UTC")
        val df: DateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm'Z'", Locale.ROOT)
        df.timeZone = tz
        return df.format(this)
    }