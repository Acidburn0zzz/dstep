/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Jan 29, 2012
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module clang.Type;

import clang.c.index;
import clang.Cursor;
import clang.Util;
import mambo.core.io;
struct Type
{
	mixin CX;

	@property string spelling ()
	{
		auto r = clang_getTypeDeclaration(cx);
		return Cursor(r).spelling;
	}
	
	@property bool isTypedef ()
	{
		return kind == CXTypeKind.CXType_Typedef;
	}
	
	@property Type canonicalType ()
	{
		auto r = clang_getCanonicalType(cx);
		return Type(r);
	}
	
	@property Type pointee ()
	{
		auto r = clang_getPointeeType(cx);
		return Type(r);
	}
	
	@property bool isFunctionType ()
	{
		with (CXTypeKind)
			return CXType_FunctionNoProto || CXType_FunctionProto;
	}
	
	@property bool isFunctionPointerType ()
	{
		with (CXTypeKind)
			return kind == CXType_Pointer && pointee.isFunctionType;
	}
	
	@property bool isObjCIdType ()
	{
		return isTypedef &&
			canonicalType.kind ==  CXTypeKind.CXType_ObjCObjectPointer &&
			spelling == "id";
	}
	
	@property bool isObjCClassType ()
	{
		return isTypedef &&
			canonicalType.kind ==  CXTypeKind.CXType_ObjCObjectPointer &&
			spelling == "Class";
	}
	
	@property bool isObjCSelType ()
	{
		with(CXTypeKind)
			if (isTypedef)
			{
				auto c = canonicalType;
				return c.kind == CXType_Pointer &&
					c.pointee.kind == CXType_ObjCSel;
			}
		
			else
				return false;
	}
	
	@property bool isObjCBuiltinType ()
	{
		return isObjCIdType || isObjCClassType || isObjCSelType;
	}

	@property bool isWideCharType ()
	{
		with (CXTypeKind)
			return kind == CXType_WChar || kind == CXType_SChar;
	}
}