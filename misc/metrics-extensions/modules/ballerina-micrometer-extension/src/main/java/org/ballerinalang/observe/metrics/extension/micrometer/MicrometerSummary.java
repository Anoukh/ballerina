/*
 * Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package org.ballerinalang.observe.metrics.extension.micrometer;

import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Tag;
import io.micrometer.core.instrument.distribution.HistogramSnapshot;
import io.micrometer.core.instrument.distribution.ValueAtPercentile;
import org.ballerinalang.util.metrics.AbstractMetric;
import org.ballerinalang.util.metrics.MetricId;
import org.ballerinalang.util.metrics.PercentileValue;
import org.ballerinalang.util.metrics.Snapshot;
import org.ballerinalang.util.metrics.StatisticConfig;
import org.ballerinalang.util.metrics.Summary;

import java.util.stream.Collectors;

/**
 * An implementation of {@link Summary} using Micrometer.
 */
public class MicrometerSummary extends AbstractMetric implements Summary {

    private final io.micrometer.core.instrument.DistributionSummary summary;

    public MicrometerSummary(MeterRegistry meterRegistry, MetricId id, StatisticConfig statisticConfig) {
        super(id);
        summary = io.micrometer.core.instrument.DistributionSummary.builder(id.getName())
                .description(id.getDescription())
                .tags(id.getTags().stream().map(tag -> Tag.of(tag.getKey(), tag.getValue()))
                        .collect(Collectors.toList()))
                .publishPercentiles(statisticConfig.getPercentiles())
                .distributionStatisticExpiry(statisticConfig.getExpiry())
                .register(meterRegistry);
    }

    @Override
    public void record(long amount) {
        summary.record(amount);
    }

    @Override
    public long getCount() {
        return summary.count();
    }

    @Override
    public long getSum() {
        return (long) summary.totalAmount();
    }

    @Override
    public Snapshot getSnapshot() {
        HistogramSnapshot histogramSnapshot = summary.takeSnapshot();
        ValueAtPercentile[] percentileValues = histogramSnapshot.percentileValues();
        PercentileValue[] values = new PercentileValue[percentileValues.length];
        for (int i = 0; i < percentileValues.length; i++) {
            ValueAtPercentile percentileValue = percentileValues[i];
            values[i] = new PercentileValue(percentileValue.percentile(), percentileValue.value());
        }
        return new Snapshot(histogramSnapshot.mean(), (long) histogramSnapshot.max(), values);
    }
}
