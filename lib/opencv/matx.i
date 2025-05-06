/* Copyright (c) 2015-2020 The OpenCV-SWIG Library Developers. See the AUTHORS file at the
 * top-level directory of this distribution and at
 * https://github.com/renatoGarcia/opencv-swig/blob/master/AUTHORS.
 *
 * This file is part of OpenCV-SWIG Library. It is subject to the 3-clause BSD license
 * terms as in the LICENSE file found in the top-level directory of this distribution and
 * at https://github.com/renatoGarcia/opencv-swig/blob/master/LICENSE. No part of
 * OpenCV-SWIG Library, including this file, may be copied, modified, propagated, or
 * distributed except according to the terms contained in the LICENSE file.
 */

%include <opencv/detail/numpy.i>

%include <std_string.i>
%include <std_vector.i>



%include <opencv/detail/matx.i>

/* %cv_matx_instantiate(type, d1, d2, type_alias, np_basic_type)
 *
 *  Generete the wrapper code to a specific cv::Matx template instantiation.
 *
 *  type - The cv::Matx value type.
 *  d1 - The number of rows.
 *  d2 - The number of columns.
 *  type_alias - The value type alias used at the cv::Matx typedefs.
 *  np_basic_type - The character code[0] describing the numpy array item type.
 *
 *  For instance, the C++ type cv::Matx<double, 2, 1> would be instantiated with:
 *
 *      %cv_matx_instantiate(double, 2, 1, d, f)
 *
 *  which would generate a wrapper Python class Matx21d.
 *
 *  [0]: http://docs.scipy.org/doc/numpy/reference/arrays.interface.html#__array_interface__
 */
%define %cv_matx_instantiate(type, d1, d2, type_alias, np_basic_type)

    %cv_numpy_add_type(type, np_basic_type)

    #if !_ARRAY_##type##_INSTANTIATED_
        %template(_##type##Array) std::vector< type >;
 
        #define _ARRAY_##type##_INSTANTIATED_
    #endif

    #if !_CV_MATX_##type##_##d1##_##d2##_INSTANTIATED_
        %template(_Matx_##type##_##d1##_##d2) cv::Matx< type, d1, d2>;
  
        #define _CV_MATX_##type##_##d1##_##d2##_INSTANTIATED_
    #endif
%enddef


%header
%{
    #include <opencv2/core/core.hpp>
    #include <sstream>

    #include <boost/preprocessor/repetition/repeat_from_to.hpp>
    #include <boost/preprocessor/repetition/enum.hpp>
    #include <boost/preprocessor/list/for_each.hpp>

    /* Macros mapping the Matx channels number to a Boost Preprocessor list[0] with the
     * arities of its constructors. Note that to a Matx with N channels, the maximum arity
     * of its constructors is N, an there aren't constructors with arities greater than
     * 16, neither constructors 15-ary, 14-ary, 13-ary or 11-ary.
     *
     * [0]: http://www.boost.org/doc/libs/release/libs/preprocessor/doc/data/lists.html
     */
    #define _0_CHANNELS_ARITIES_LIST (0, BOOST_PP_NIL)
    #define _1_CHANNELS_ARITIES_LIST (1, _0_CHANNELS_ARITIES_LIST)
    #define _2_CHANNELS_ARITIES_LIST (2, _1_CHANNELS_ARITIES_LIST)
    #define _3_CHANNELS_ARITIES_LIST (3, _2_CHANNELS_ARITIES_LIST)
    #define _4_CHANNELS_ARITIES_LIST (4, _3_CHANNELS_ARITIES_LIST)
    #define _5_CHANNELS_ARITIES_LIST (5, _4_CHANNELS_ARITIES_LIST)
    #define _6_CHANNELS_ARITIES_LIST (6, _5_CHANNELS_ARITIES_LIST)
    #define _7_CHANNELS_ARITIES_LIST (7, _6_CHANNELS_ARITIES_LIST)
    #define _8_CHANNELS_ARITIES_LIST (8, _7_CHANNELS_ARITIES_LIST)
    #define _9_CHANNELS_ARITIES_LIST (9, _8_CHANNELS_ARITIES_LIST)
    #define _10_CHANNELS_ARITIES_LIST (10, _9_CHANNELS_ARITIES_LIST)
    #define _11_CHANNELS_ARITIES_LIST _10_CHANNELS_ARITIES_LIST
    #define _12_CHANNELS_ARITIES_LIST (12, _10_CHANNELS_ARITIES_LIST)
    #define _13_CHANNELS_ARITIES_LIST _12_CHANNELS_ARITIES_LIST
    #define _14_CHANNELS_ARITIES_LIST _12_CHANNELS_ARITIES_LIST
    #define _15_CHANNELS_ARITIES_LIST _12_CHANNELS_ARITIES_LIST
    #define _16_CHANNELS_ARITIES_LIST (16, _12_CHANNELS_ARITIES_LIST)


    #define ARITIES_LIST(channels) _##channels##_CHANNELS_ARITIES_LIST

    #define ARG(z, n, data) arg[n]
    #define ELSE_IF_STATEMENT(r, data, n)                                   \
        else if (arg.size() == n)                                           \
        {                                                                   \
            return new M(BOOST_PP_ENUM(n, ARG, _));                         \
        }
    #define IF_ELSE_CHAIN(channels) if (false);                             \
        BOOST_PP_LIST_FOR_EACH(ELSE_IF_STATEMENT, _, ARITIES_LIST(channels))


    /* Factory to Matx with 10 channels or more.
     *
     * It should be 16 channels, but as of OpenCV 3.0.0, there are a bug at which only
     * Matx's with exactly 12 or 16 channels can call a 12-ary or 16-ary constructors
     * respectively.
     */
    template <typename M, int Channels=M::channels>
    struct Factory
    {
        static M* construct(std::vector<typename M::value_type> const& arg)
        {
            IF_ELSE_CHAIN(10)
            return NULL;
        }
    };

    #define FACTORY(z, channels, data)                                      \
        template <typename M>                                               \
        struct Factory<M, channels>                                         \
        {                                                                   \
            static M* construct(std::vector<typename M::value_type> const& arg) \
            {                                                               \
                IF_ELSE_CHAIN(channels)                                     \
                return NULL;                                                \
            }                                                               \
        };

    BOOST_PP_REPEAT_FROM_TO(1, 10, FACTORY, _)


    template <int A, int B>
    struct MinInt
    {
        enum
        {
            value = (A < B) ? A : B
        };
    };

%}

%extend cv::Matx
{


    Matx(std::vector<value_type> arg)
    {
        return Factory< $parentclassname >::construct(arg);
    }


   

    std::string __str__()
    {
        std::ostringstream s;
        s << *$self;
        return s.str();
    }
}


/* %cv_matx_instantiate_defaults
 *
 * Generate a wrapper class to all cv::Matx which has a typedef on OpenCV header file.
 */
%define %cv_matx_instantiate_defaults
    %cv_matx_instantiate(float, 1, 2, f, f)
    %cv_matx_instantiate(double, 1, 2, d, f)
    %cv_matx_instantiate(float, 1, 3, f, f)
    %cv_matx_instantiate(double, 1, 3, d, f)
    %cv_matx_instantiate(float, 1, 4, f, f)
    %cv_matx_instantiate(double, 1, 4, d, f)
    %cv_matx_instantiate(float, 1, 6, f, f)
    %cv_matx_instantiate(double, 1, 6, d, f)

    %cv_matx_instantiate(float, 2, 1, f, f)
    %cv_matx_instantiate(double, 2, 1, d, f)
    %cv_matx_instantiate(float, 3, 1, f, f)
    %cv_matx_instantiate(double, 3, 1, d, f)
    %cv_matx_instantiate(float, 4, 1, f, f)
    %cv_matx_instantiate(double, 4, 1, d, f)
    %cv_matx_instantiate(float, 6, 1, f, f)
    %cv_matx_instantiate(double, 6, 1, d, f)

    %cv_matx_instantiate(float, 2, 2, f, f)
    %cv_matx_instantiate(double, 2, 2, d, f)
    %cv_matx_instantiate(float, 2, 3, f, f)
    %cv_matx_instantiate(double, 2, 3, d, f)
    %cv_matx_instantiate(float, 3, 2, f, f)
    %cv_matx_instantiate(double, 3, 2, d, f)

    %cv_matx_instantiate(float, 3, 3, f, f)
    %cv_matx_instantiate(double, 3, 3, d, f)

    %cv_matx_instantiate(float, 3, 4, f, f)
    %cv_matx_instantiate(double, 3, 4, d, f)
    %cv_matx_instantiate(float, 4, 3, f, f)
    %cv_matx_instantiate(double, 4, 3, d, f)

    %cv_matx_instantiate(float, 4, 4, f, f)
    %cv_matx_instantiate(double, 4, 4, d, f)
    %cv_matx_instantiate(float, 6, 6, f, f)
    %cv_matx_instantiate(double, 6, 6, d, f)
%enddef
