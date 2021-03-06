package com.project5e.react.navigation.data.bus

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData

object Store {
    private val store = HashMap<String, MutableLiveData<Any?>>()

    @JvmStatic
    fun reducer(action: String): LiveData<Any?>? {
        store[action] = MutableLiveData()
        return store[action]
    }

    @JvmStatic
    fun dispatch(action: String, state: Any? = null) {
        if (!store.containsKey(action)) return
        store[action]?.postValue(state)
    }

}
