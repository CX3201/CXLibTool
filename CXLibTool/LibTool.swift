//
//  LibTool.swift
//  CXLibTool
//
//  Created by abelchen on 2018/8/8.
//  Copyright © 2018年 com.tencent.abelchen. All rights reserved.
//

import Foundation

let runtimeMagic = String(format:"%.0f", NSTimeIntervalSince1970)

func fileArchitectures(fileURL:URL) -> Any? {
    let result = bash(command:"lipo", arguments: ["-info", fileURL.path])
    let isFat = result.range(of:"Non-fat") == nil
    guard let index = result.range(of:"re: ")?.upperBound else {
        return nil
    }
    let archStr = result[index..<result.endIndex]
    var archs = archStr.components(separatedBy: CharacterSet(charactersIn:" "))
    archs = archs.filter { (str) -> Bool in
        return str.count > 0
    }
    if(isFat){
        return archs
    }else{
        return archs.first
    }
}

func unArchiveFile(fileURL:URL, archs:[String]) -> Bool {
    let path = URL(fileURLWithPath: NSTemporaryDirectory())
    let fileName = fileURL.deletingPathExtension().lastPathComponent
    for arch in archs {
        let tmpFilePath = path.appendingPathComponent(fileName + runtimeMagic + arch)
        let result = bash(command:"lipo", arguments: ["-thin", arch, fileURL.path, "-output", tmpFilePath.path])
        if result.count > 0 {
            return false
        }
    }
    return true
}

func archiveFile(fileURL:URL, archs:[String]) -> Bool {
    let path = URL(fileURLWithPath: NSTemporaryDirectory())
    let fileName = fileURL.deletingPathExtension().lastPathComponent
    var args = ["-create"]
    for arch in archs {
        let tmpFilePath = path.appendingPathComponent(fileName + runtimeMagic + arch)
        args.append(tmpFilePath.path)
    }
    args.append(contentsOf: ["-output", fileURL.path])
    let result = bash(command:"lipo", arguments: args)
    if result.count > 0 {
        return false
    }
    return true
}

func objectsInFile(fileURL:URL, arch:String) -> [String] {
    let path = URL(fileURLWithPath: NSTemporaryDirectory())
    let fileName = fileURL.deletingPathExtension().lastPathComponent
    let tmpFilePath = path.appendingPathComponent(fileName + runtimeMagic + arch)
    return objectsInFile(fileURL: tmpFilePath)
}

func objectsInFile(fileURL:URL) -> [String] {
    let result = bash(command:"ar", arguments: ["-t", fileURL.path])
    if result.count == 0 {
        return []
    }
    let objects = result.components(separatedBy: "\n").filter { (object) -> Bool in
        return object.hasSuffix(".o") || object.hasSuffix(".O")
    }
    return objects
}

func removeObjectsInFile(fileURL:URL, arch:String, object:String) -> Bool {
    let path = URL(fileURLWithPath: NSTemporaryDirectory())
    let fileName = fileURL.deletingPathExtension().lastPathComponent
    let tmpFilePath = path.appendingPathComponent(fileName + runtimeMagic + arch)
    return removeObjectsInFile(fileURL: tmpFilePath, object:object)
}

func removeObjectsInFile(fileURL:URL, object:String) -> Bool {
    let result = bash(command:"ar", arguments: ["-d", fileURL.path, object])
    if result.count > 0 {
        return false
    }
    return true
}

