# TNullable





## Nullable Types

A `Nullable` type, is used to represent the presence or absence of a value. In programming languages where types are usually non-nullable (meaning variables cannot be assigned a `null` or `nil` value), a nullable type provides a way to express the absence of a value.

The concept of `Nullable` is commonly used in languages like C#, Swift, Kotlin, and others. The idea is to allow a variable to be explicitly set to a special "null" value in addition to its regular type. This can be useful in various scenarios:

1. **Database Interactions:**
   - When working with databases, certain fields in a record may not have a value. Instead of using a default value (e.g., zero or an empty string) to indicate the absence of data, a nullable type can be used.

2. **Optional Function Parameters:**
   - When designing functions or methods, you might have parameters that are optional. Using a nullable type allows you to pass `null` for optional parameters, indicating that the parameter is not specified.

3. **Avoiding Ambiguous Values:**
   - In situations where a specific value is a valid input, using `null` as a separate indicator of absence can help avoid ambiguity. For example, if zero is a valid value, using `null` to indicate "no value" prevents confusion.

4. **Avoiding Magic Values:**
   - Instead of using magic values that represent the absence of data (e.g., -1 or an empty string), nullable types provide a clear and type-safe way to express the absence of a value.

5. **Error Handling:**
   - Nullable types can be useful in error-handling scenarios where the absence of a value indicates an error condition. For example, a function that searches for an element in a collection might return a nullable type to indicate that the element was not found.


## Implementation of Nullable in Delphi.

Pascal does not have a built-in concept of nullable types similar to languages like C# or Swift. In Pascal, variables of simple types (like integers, strings, etc.) cannot be set to a null or undefined state.  

However, there are some language features and conventions that can be used to achieve similar functionality. 

**TNullabe** is an example of a simple way to create a nullable-like structure in Delphi using a record with a boolean flag.

### Using Record to implement Nullable    

Nullables in Delphi can be implemented using a record. All you need is a value, and some flag that will tell you whether or not the value has been explicitly set or not.

```pascal 
type
  TNullable<T> = record
  private
    FHasValue: Boolean;
    FValue: T;
    function GetValue: T;
    procedure SetValue(AValue: T);
  public
    property HasValue: Boolean read FHasValue;
    property Value: T read GetValue write SetValue;
  end;
```

In Delphi, **records are not automatically initialized** by default. Unlike objects or dynamic arrays, which are automatically initialized to a default state when created, records in Delphi are not automatically initialized to zero or any other default values.

The **FHasValue** boolean variable, that is **non-managed or unmanaged type**, can hold a **random value**.    


## Record automatic initialization   

In Delphi there are some language features that can be used to achieve record automatic initialization.  

### Nullable with Custom Managed Records


Delphi has introduced the concept of *"Managed Records"* as a language feature with the release of Delphi 10.4 Sydney, where record type supports custom initialization and finalization, beyond the default operations the compiler does for managed records.   

```pascal 
type
  TNullable<T> = record
  private
    FHasValue: Boolean;
    ....
    {$IF (CompilerVersion >= 34)} // From RAD Studio 10.4 Sydney
    class operator Initialize(out Dest: TNullable<T>);
    class operator Finalize(var Dest: TNullable<T>);
    {$ENDIF}
    ....
  public
    ....
  end;
```

Using Initialization, it is easy to implement automatic initialization of FHasValue.

```pascal 
{$IF (CompilerVersion >= 34)} // From RAD Studio 10.4 Sydney
class operator TNullable<T>.Initialize(out Dest: TNullable<T>);
begin
  Dest.FHasValue := False;
end;
{$ENDIF}
```


## Attributions and Credits

Allen Bauer's post [A "Nullable" Post][0]   
Dalija Prasnikar post [Delphi Nullable with Custom Managed Records][1]  
Marco Cantu post [Custom Managed Records Coming to Delphi 10.4][2]     
Barry Kelly post [Smart pointers in Delphi][3]  
Synopse post [ORM TNullable* fields for NULL storage][6]  
Spring4D [Nullable implementation][4].   
Landgraf.dev [Nullable implementation][7].   
Paulo Rossi [Neon - JSON Serialization Library for Delphi][8]

[0]: https://blog.therealoracleatdelphi.com/2008/09/a-post_18.html   
[1]: https://dalijap.blogspot.com/2020/05/delphi-nullable-with-custom-managed.html
[2]: https://blog.marcocantu.com/blog/2020-may-custom-managed-records.html
[3]: http://blog.barrkel.com/2008/09/smart-pointers-in-delphi.html
[4]: https://bitbucket.org/sglienke/spring4d/src/master/
[5]: https://github.com/spring4d/spring4d
[6]: https://blog.synopse.info/?post/2015/09/25/ORM-TNullable%2A-fields-for-NULL-storage
[7]: https://github.com/landgraf-dev/aws-sdk-delphi/blob/master/Source/Core/AWS.Nullable.pas
[8]: https://github.com/paolo-rossi/delphi-neon/blob/master/Source/Neon.Core.Nullables.pas
