//
//  Copyright © 2018 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Foundation/Foundation.h>

/**
 *  Insert an object or NSNull into a collection
 *
 *  @param dict   a mutable dictionary
 *  @param object an object or nil
 */
void PNLiteDictSetSafeObject(NSMutableDictionary *dict, id object,
                          id<NSCopying> key);

/**
 *  Insert an object or NSNull into a collection
 *
 *  @param array  a mutable array
 *  @param object an object or nil
 */
void PNLiteArrayAddSafeObject(NSMutableArray *array, id object);

/**
 *  Insert an object into a collection only if not nil
 *
 *  @param dict   a mutable dictionary
 *  @param object an object or nil
 *  @param key    the key of the object
 */
void PNLiteDictInsertIfNotNil(NSMutableDictionary *dict, id object,
                           id<NSCopying> key);

/**
 *  Insert an object into a collection only if not nil
 *
 *  @param array  a mutable array
 *  @param object an object or nil
 */
void PNLiteArrayInsertIfNotNil(NSMutableArray *array, id object);
