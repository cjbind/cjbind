package cjbind_ffi

func require(condition: Bool, message: String): Unit {
    if (!condition) {
        throw Exception(message)
    }
}

main(): Int64 {
    unsafe {
        require(lifecycle_live_count() == 0, "unexpected initial live count")

        let first = LibC.malloc<LifecycleProbe_LifecycleProbe>(count: 1)
        LifecycleProbe_LifecycleProbe_constructor(first)
        require(lifecycle_live_count() == 1, "default constructor was not observed")
        require(LifecycleProbe_value(first) == 7, "default constructor selected the wrong overload")
        require(LifecycleProbe_add(19, 23) == 42, "static method returned the wrong value")
        LifecycleProbe_LifecycleProbe_destructor(first)
        LibC.free(first)
        require(lifecycle_live_count() == 0, "first destructor was not observed")

        let second = LibC.malloc<LifecycleProbe_LifecycleProbe>(count: 1)
        LifecycleProbe_LifecycleProbe_constructor1(second, 37)
        require(lifecycle_live_count() == 1, "value constructor was not observed")
        require(LifecycleProbe_value(second) == 37, "value constructor selected the wrong overload")
        LifecycleProbe_LifecycleProbe_destructor(second)
        LibC.free(second)
        require(lifecycle_live_count() == 0, "second destructor was not observed")

        let multiple = LibC.malloc<MultipleProbe_MultipleProbe>(count: 1)
        MultipleProbe_MultipleProbe_constructor(multiple, 40)
        require(MultipleProbe_left(multiple) == 41, "primary-base method used the wrong receiver")
        require(MultipleProbe_right(multiple) == 42, "secondary-base method used the wrong receiver")
        MultipleProbe_MultipleProbe_destructor(multiple)
        LibC.free(multiple)
    }
    return 0
}
