//
//  RKDictionaryTransformer.swift
//
//  Copyright (c) 2016 Luciano Polit <lucianopolit@gmail.com>
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

import PromiseKit

/// It contains the methods to transform the *Dictionary Entities*.
public class RKDictionaryTransformer {
    
    /**
     Given two `RKDictionaryEntity`, it merges them and returns the result of the merging.
     It copies everything of the new dictionary into the old one.
     
     - Parameter old: The old `Dictionary` that is used to make the merge.
     - Parameter new: The new `Dictionary` that is used to make the merge.
     
     - Returns: The result of the merging.
     */
    public class func merge(old: RKDictionaryEntity, new: RKDictionaryEntity) -> RKDictionaryEntity {
        
        var dictionary = old
        
        for (key, value) in new {
            dictionary[key] = value
        }
        
        return dictionary
        
    }
    
    /**
     Given two `RKDictionaryEntity`, it compares everything and returns the result difference between them.
     If something exists in the old one and not in the new one, add null to the field.
     If something exists in the new one and not in the old one, add the value to the field.
     If something exists in both, compare them, and if they are different, add the new one to the field.
     
     - Parameter old: The old `Dictionary` that is used to make the merge.
     - Parameter new: The new `Dictionary` that is used to make the merge.
     
     - Returns: A promise of the result of the merging.
     */
    public class func difference(old: RKDictionaryEntity, new: RKDictionaryEntity) -> RKDictionaryEntity {
        
        var dictionary = RKDictionaryEntity()
        
        // Iterate over the new dictionary to find the new differences.
        for (key, value) in new {
            
            // No compare arrays.
            if value is Array<Any> { continue }
            
            // Check if it is a dictionary.
            if let newDictionary = value as? RKDictionaryEntity {
                // Check if it exists in the old one and it is a dictionary.
                if let oldDictionary = old[key] as? RKDictionaryEntity {
                    // If it exists, get the difference.
                    let diff: RKDictionaryEntity = difference(old: oldDictionary, new: newDictionary)
                    // add the field with the new difference.
                    if !diff.isEmpty { dictionary[key] = diff }
                } else {
                    // If it does not exist, add the field with the new dictionary.
                    dictionary[key] = newDictionary
                }
                
                // Do not continue iterating.
                continue
            }
            
            // Check if it exists in the old one.
            if let oldValue = old[key] as AnyObject? {
                // If it exists, compare them.
                if !oldValue.isEqual(value) {
                    // If they are different, add it.
                    dictionary[key] = value
                }
            } else {
                // If not exists, add it.
                dictionary[key] = value
            }
            
        }
        
        // Iterate over the old dictionary to find if something has been deleted.
        for (key, value) in old {
            
            // No compare arrays.
            if value is Array<Any> { continue }
            
            // Check if if exists in the new one.
            if new[key] == nil {
                // If not exists, add null.
                dictionary[key] = NSNull()
            }
            
        }
        
        return dictionary
        
    }
    
}
