package com.jumio.jumiomobilesdk

import java.util.*

/**
 * Remove null values from this map.
 */
fun <K, V> Map<K, V?>.compact(): Map<K, V> = filter { it.value != null }.mapValues { it.value!! }

/**
 * Returns a map that contains the same values as the original map, but with the keys transformed
 * to their lowercase counterparts. If two keys become equal in this way, the latter one's
 * associated value will be retained.
 */
fun <V> Map<String, V>.withLowercaseKeys() = mapKeys { it.key.toLowerCase(Locale.ROOT) }