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

package org.ballerinalang.nativeimpl.observe.tracing;

import io.opentracing.Tracer;
import org.ballerinalang.bre.Context;
import org.ballerinalang.bre.bvm.WorkerExecutionContext;
import org.ballerinalang.config.ConfigRegistry;
import org.ballerinalang.util.codegen.ServiceInfo;
import org.ballerinalang.util.observability.ObservabilityUtils;
import org.ballerinalang.util.observability.ObserverContext;
import org.ballerinalang.util.observability.TracingUtils;
import org.ballerinalang.util.tracer.BSpan;
import org.ballerinalang.util.tracer.TracersStore;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import static org.ballerinalang.util.observability.ObservabilityConstants.CONFIG_TRACING_ENABLED;
import static org.ballerinalang.util.observability.ObservabilityConstants.KEY_OBSERVER_CONTEXT;
import static org.ballerinalang.util.observability.ObservabilityConstants.KEY_USER_TRACE_CONTEXT;
import static org.ballerinalang.util.observability.ObservabilityConstants.PROPERTY_TRACE_PROPERTIES;
import static org.ballerinalang.util.observability.ObservabilityConstants.PROPERTY_USER_TRACE_PROPERTIES;
import static org.ballerinalang.util.observability.ObservabilityConstants.SERVICE_INFO;
import static org.ballerinalang.util.observability.ObservabilityConstants.UNKNOWN_SERVICE;
import static org.ballerinalang.util.tracer.TraceConstants.KEY_SPAN;

/**
 * This class wraps opentracing apis and exposes native functions to use within ballerina.
 */
public class OpenTracerBallerinaWrapper {

    private static OpenTracerBallerinaWrapper instance = new OpenTracerBallerinaWrapper();
    private TracersStore tracerStore;
    private final boolean enabled;

    public OpenTracerBallerinaWrapper() {
        enabled = ConfigRegistry.getInstance().getAsBoolean(CONFIG_TRACING_ENABLED);
        tracerStore = TracersStore.getInstance();
    }

    public static OpenTracerBallerinaWrapper getInstance() {
        return instance;
    }

    /**
     * Method to start a span using parent span context.
     *
     * @param spanName    name of the span
     * @param tags        key value paired tags to attach to the span
     * @param isUserTrace if the span is related to a user trace or ootb trace
     * @param context     native context
     * @return unique id of the created span
     */
    public ObserverContext startSpan(String spanName, Map<String, String> tags, boolean isUserTrace, Context context) {

        if (!enabled) {
            return null;
        }

        WorkerExecutionContext parentCtx = context.getParentWorkerExecutionContext();
        ServiceInfo serviceInfo = (ServiceInfo) parentCtx.globalProps.get(SERVICE_INFO);
        String serviceName = serviceInfo != null ? serviceInfo.getType().toString() : UNKNOWN_SERVICE;
        Tracer tracer = tracerStore.getTracer(serviceName);
        if (tracer == null) {
            return null;
        }

        ObserverContext observerContext = new ObserverContext();
        observerContext.setServiceName(serviceName);
        observerContext.setResourceName(spanName);
        tags.forEach((observerContext::addTag));

        if (isUserTrace) {

            observerContext.setUserTrace();
            Optional<ObserverContext> optionalParentContext = ObservabilityUtils.getParentContext(context);
            optionalParentContext.ifPresent(parentContext -> observerContext.addProperty(
                    PROPERTY_USER_TRACE_PROPERTIES, parentContext.getGlobalProps().get(PROPERTY_TRACE_PROPERTIES)
            ));
            Map<String, Object> localProps = parentCtx.localProps;
            if (localProps == null) {
                localProps = new HashMap<>();
                parentCtx.localProps = localProps;
            }
            ObserverContext userTraceContext = (ObserverContext) localProps.get(KEY_USER_TRACE_CONTEXT);
            if (userTraceContext != null) {
                observerContext.setParent(userTraceContext);
            }
            parentCtx.localProps.put(KEY_USER_TRACE_CONTEXT, observerContext);

        } else {

            Optional<ObserverContext> optionalParentContext = ObservabilityUtils.getParentContext(context);
            optionalParentContext.ifPresent(parentContext -> {
                BSpan bSpan = (BSpan) parentContext.getProperty(KEY_SPAN);
                if (bSpan != null) {
                    observerContext.setParent(parentContext);
                    observerContext.addProperty(KEY_SPAN, new BSpan(observerContext, false));
                }
            });

            ObservabilityUtils.setObserverContextToWorkerExecutionContext(
                    parentCtx, observerContext);
        }

        TracingUtils.startObservation(observerContext, false);
        return observerContext;
    }

    /**
     * Method to mark a span as finished.
     *
     * @param observerContext observer context
     * @param isUserTrace     if the span is related to a user trace or ootb trace
     * @param context         native context
     */
    public void finishSpan(ObserverContext observerContext, boolean isUserTrace, Context context) {
        if (enabled) {
            TracingUtils.stopObservation(observerContext);
            if (isUserTrace) {
                context.getParentWorkerExecutionContext()
                        .localProps.put(KEY_USER_TRACE_CONTEXT, observerContext.getParent());
            } else {
                context.getParentWorkerExecutionContext()
                        .localProps.put(KEY_OBSERVER_CONTEXT, observerContext.getParent());
            }
        }
    }

    /**
     * Method to add tags to an existing span.
     *
     * @param tagKey          the key of the tag
     * @param tagValue        the value of the tag
     * @param observerContext observer context
     */
    public void addTags(String tagKey, String tagValue, ObserverContext observerContext) {
        if (enabled) {
            observerContext.addTag(tagKey, tagValue);
        }
    }
}
