//
//  wirtual_joy_helper.hpp
//  wjoy
//
//  Created by Ian Gregory on 18 Jun ’20.
//

#ifndef WIRTUAL_JOY_HELPER_HPP
#define WIRTUAL_JOY_HELPER_HPP

#include <libkern/libkern.h>

template<class Integral>
inline OSNumber *wirtual_joy_make_osnumber(Integral n)
{
    return OSNumber::withNumber(
        n,              // number to store
        8 * sizeof n    // size in bits
    );
}

#endif /* WIRTUAL_JOY_HELPER_HPP */
