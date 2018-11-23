// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

public type GroupBy object {
    public function (StreamEvent[]) nextProcessorPointer;
    public string[] groupByFields;
    public map groupedStreamEvents = {};

    new (nextProcessorPointer, groupByFields) {
    }

    public function process(StreamEvent[] streamEvents) {
        if (self.groupByFields.length() > 0) {
            foreach streamEvent in streamEvents {
                string key = self.generateGroupByKey(streamEvent);
                if (!self.groupedStreamEvents.hasKey(key)) {
                    StreamEvent[] events = [];
                    self.groupedStreamEvents[key] = events;
                }
                var groupedEvents = <StreamEvent[]> self.groupedStreamEvents[key];
                if (groupedEvents is StreamEvent[]) {
                    groupedEvents[groupedEvents.length()] = streamEvent;
                } else if (groupedEvents is error) {
                    panic groupedEvents;
                }
            }

            foreach arr in self.groupedStreamEvents.values() {
                var eventArr = <StreamEvent[]>arr;
                if (eventArr is StreamEvent[]) {
                    self.nextProcessorPointer(eventArr);
                } else if (eventArr is error) {
                    panic eventArr;
                }
            }
        } else {
            self.nextProcessorPointer(streamEvents);
        }
    }

    function generateGroupByKey(StreamEvent event) returns string {
        string key = "";

        foreach field in self.groupByFields {
            key += ", ";
            string? fieldValue = <string> event.data[field];
            match fieldValue {
                string value => {
                    key += value;
                }
                () => {

                }
            }
        }

        return key;
    }
};

public function createGroupBy(function(StreamEvent[]) nextProcPointer, string[] groupByFields) returns GroupBy {
    GroupBy groupBy = new (nextProcPointer, groupByFields);
    return groupBy;
}