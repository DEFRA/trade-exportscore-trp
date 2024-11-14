//imports
import * as comTypes from 'br/commonRegistry:commontypes:0-latest'
import * as comFuncs from 'br/commonRegistry:commonfunctions:0-latest'

//Generic Params
param location string
param tags comTypes.tagsObject
param date string = utcNow('yyyyMMdd')

param name string
param skuName string

module workspace 'br/public:avm/res/operational-insights/workspace:0.8.0' = {
  name: '${name}-${date}'
  params: {
    name: name
    location: location
    skuName: skuName
    tags: comFuncs.tagBuilder(name, date, tags)
  }
}
