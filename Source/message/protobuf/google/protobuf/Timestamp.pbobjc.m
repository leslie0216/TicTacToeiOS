// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: google/protobuf/timestamp.proto

#import "GPBProtocolBuffers_RuntimeSupport.h"
#import "google/protobuf/Timestamp.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma mark - GPBTimestampRoot

@implementation GPBTimestampRoot

@end

#pragma mark - GPBTimestampRoot_FileDescriptor

static GPBFileDescriptor *GPBTimestampRoot_FileDescriptor(void) {
  // This is called by +initialize so there is no need to worry
  // about thread safety of the singleton.
  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPBDebugCheckRuntimeVersion();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@"google.protobuf"
                                                     syntax:GPBFileSyntaxProto3];
  }
  return descriptor;
}

#pragma mark - GPBTimestamp

@implementation GPBTimestamp

@dynamic seconds;
@dynamic nanos;

typedef struct GPBTimestamp__storage_ {
  uint32_t _has_storage_[1];
  int32_t nanos;
  int64_t seconds;
} GPBTimestamp__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "seconds",
        .number = GPBTimestamp_FieldNumber_Seconds,
        .hasIndex = 0,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt64,
        .offset = offsetof(GPBTimestamp__storage_, seconds),
        .defaultValue.valueInt64 = 0LL,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
      {
        .name = "nanos",
        .number = GPBTimestamp_FieldNumber_Nanos,
        .hasIndex = 1,
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeInt32,
        .offset = offsetof(GPBTimestamp__storage_, nanos),
        .defaultValue.valueInt32 = 0,
        .dataTypeSpecific.className = NULL,
        .fieldOptions = NULL,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[GPBTimestamp class]
                                     rootClass:[GPBTimestampRoot class]
                                          file:GPBTimestampRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:sizeof(fields) / sizeof(GPBMessageFieldDescription)
                                        oneofs:NULL
                                    oneofCount:0
                                         enums:NULL
                                     enumCount:0
                                        ranges:NULL
                                    rangeCount:0
                                   storageSize:sizeof(GPBTimestamp__storage_)
                                    wireFormat:NO];
    NSAssert(descriptor == nil, @"Startup recursed!");
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


// @@protoc_insertion_point(global_scope)
