package com.jmarkstar.bledemo

import android.os.Parcelable
import java.io.Serializable

interface GattInfoItem: Parcelable {

    companion object {
        val GATT_SERVICE: Int
            get() = 1

        val GATT_CHARACTERISTIC: Int
            get() = 2
    }

    fun getGattItemType(): Int
}