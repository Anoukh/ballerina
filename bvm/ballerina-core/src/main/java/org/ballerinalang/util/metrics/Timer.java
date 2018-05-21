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
package org.ballerinalang.util.metrics;

import java.time.Duration;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.TimeUnit;

/**
 * Track the duration distribution of events.
 */
public interface Timer extends Metric {

    /**
     * Create new builder for {@link Timer}.
     *
     * @param name The name of the metric.
     * @return The builder for {@link Timer}.
     */
    static Builder builder(String name) {
        return new Builder(name);
    }

    /**
     * Builder for {@link Timer}s.
     */
    class Builder implements Metric.Builder<Builder, Timer> {

        private final String name;
        // Expecting at least 10 tags
        private final Set<Tag> tags = new HashSet<>(10);
        private String description;

        private StatisticConfig.Builder statisticConfigBuilder = StatisticConfig.builder();

        private Builder(String name) {
            this.name = name;
        }

        @Override
        public Builder description(String description) {
            this.description = description;
            return this;
        }

        @Override
        public Builder tags(String... keyValues) {
            Tags.tags(this.tags, keyValues);
            return this;
        }

        @Override
        public Builder tags(Iterable<Tag> tags) {
            Tags.tags(this.tags, tags);
            return this;
        }

        @Override
        public Builder tag(String key, String value) {
            Tags.tags(this.tags, key, value);
            return this;
        }

        @Override
        public Builder tags(Map<String, String> tags) {
            Tags.tags(this.tags, tags);
            return this;
        }

        /**
         * @param percentiles Percentiles to compute and publish. Percentile is in the domain [0,1].
         *                    For example, the 95th percentile should be expressed as {@code 0.95}.
         * @return This builder instance.
         * @see StatisticConfig.Builder#percentiles(double...)
         */
        public Builder percentiles(double... percentiles) {
            statisticConfigBuilder.percentiles(percentiles);
            return this;
        }

        /**
         * @param expiry The duration of samples used to compute statistics.
         * @return This builder instance.
         * @see StatisticConfig.Builder#expiry(Duration)
         */
        public Builder expiry(Duration expiry) {
            statisticConfigBuilder.expiry(expiry);
            return this;
        }

        @Override
        public Timer register() {
            return register(DefaultMetricRegistry.getInstance());
        }

        @Override
        public Timer register(MetricRegistry registry) {
            return registry.timer(new MetricId(name, description, tags), statisticConfigBuilder.build());
        }
    }

    /**
     * Updates the statistics kept by the timer with the specified amount.
     *
     * @param amount Duration of a single event being measured by this timer.
     * @param unit   Time unit for the amount being recorded.
     */
    void record(long amount, TimeUnit unit);

    /**
     * Updates the statistics kept by the counter with the specified amount.
     *
     * @param duration Duration of a single event being measured by this timer.
     */
    default void record(Duration duration) {
        record(duration.toNanos(), TimeUnit.NANOSECONDS);
    }

    /**
     * Returns the number of times that record has been called since this timer was created.
     *
     * @return The number of values recorded.
     */
    long getCount();

    /**
     * Returns the total time of all recorded events.
     *
     * @param unit The base unit of time to scale the sum to.
     * @return The sum of all recorded durations.
     */
    double getSum(TimeUnit unit);

    /**
     * Returns a snapshot of the values.
     *
     * @param unit The base unit of time to scale the snapshot values to.
     * @return A snapshot of all distribution statistics at a point in time.
     */
    Snapshot getSnapshot(TimeUnit unit);
}
