// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_gcp_cloud_run_suppression.dart';

const _tracerName = 'dartastic_otel_libs_gcp_cloud_run';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class GcpCloudRunResult {
  const GcpCloudRunResult({
    this.project,
    this.region,
    this.resourceKind,
    this.serviceName,
    this.revision,
    this.trafficSplit,
    this.image,
    this.cpu,
    this.memory,
    this.minInstances,
    this.maxInstances,
    this.concurrency,
    this.timeoutSec,
    this.executionEnvironment,
    this.startupCpuBoost,
    this.useHttp2,
    this.invokerAuth,
    this.cloudSqlInstances,
    this.vpcConnector,
    this.jobName,
    this.executionName,
    this.taskCount,
    this.parallelism,
    this.executionStatus,
    this.coldStart,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  final String? project;
  final String? region;

  /// `service`, `revision`, `job`, `execution`, `task`, `domain_mapping`.
  final String? resourceKind;

  // ── Service ────────────────────────────────────────────────────
  final String? serviceName;
  final String? revision;

  /// `revision=percent,revision=percent` (e.g. `r1=90,r2=10`).
  final String? trafficSplit;

  final String? image;

  /// Cores requested (e.g. `1`, `2`, `4`, `8`).
  final String? cpu;

  /// `256Mi`, `512Mi`, `1Gi`, ...
  final String? memory;

  final int? minInstances;
  final int? maxInstances;

  final int? concurrency;
  final int? timeoutSec;

  /// `gen1`, `gen2`.
  final String? executionEnvironment;

  final bool? startupCpuBoost;
  final bool? useHttp2;

  /// `allUsers`, `allAuthenticatedUsers`, `IAM`.
  final String? invokerAuth;

  final List<String>? cloudSqlInstances;
  final String? vpcConnector;

  // ── Jobs ──────────────────────────────────────────────────────
  final String? jobName;
  final String? executionName;
  final int? taskCount;
  final int? parallelism;

  /// `SUCCEEDED`, `FAILED`, `RUNNING`, `PENDING`, `CANCELLED`.
  final String? executionStatus;

  /// Recorded only on invocation (set on `invoke`).
  final bool? coldStart;

  final String? errorCode;
  final String? errorMessage;
  final int? statusCode;
}

class GcpCloudRunCallResult<T> {
  const GcpCloudRunCallResult({required this.value, this.result});
  final T value;
  final GcpCloudRunResult? result;
}

/// Wraps a Cloud Run call in a CLIENT span. [operation] is one of
/// `services.create`, `services.update`, `services.delete`,
/// `services.get`, `services.list`, `services.setIamPolicy`,
/// `services.getIamPolicy`, `services.replaceService`,
/// `revisions.get`, `revisions.list`, `revisions.delete`,
/// `domainMappings.create`, `domainMappings.delete`,
/// `jobs.create`, `jobs.update`, `jobs.delete`, `jobs.get`, `jobs.list`,
/// `jobs.run`, `executions.get`, `executions.list`, `executions.cancel`,
/// `tasks.get`, `tasks.list`, `invoke.https`, `invoke.eventarc`,
/// `invoke.pubsubPush`, `invoke.scheduler`, `invoke.tasks`.
Future<T> tracedGcpCloudRun<T>({
  required String operation,
  required Future<GcpCloudRunCallResult<T>> Function() invoke,
}) async {
  if (gcpCloudRunInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'gcp_cloud_run',
    'rpc.method': operation,
    'gcp_cloud_run.operation': operation,
  };

  final span = _tracer().startSpan(
    'gcp_cloud_run $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.project != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_run.project',
          res.project!,
        ));
      }
      if (res.region != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_run.region',
          res.region!,
        ));
      }
      if (res.resourceKind != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_run.resource.kind',
          res.resourceKind!,
        ));
      }
      if (res.serviceName != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_run.service.name',
          res.serviceName!,
        ));
      }
      if (res.revision != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_run.revision',
          res.revision!,
        ));
      }
      if (res.trafficSplit != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_run.traffic_split',
          res.trafficSplit!,
        ));
      }
      if (res.image != null) {
        extras.add(OTel.attributeString('gcp_cloud_run.image', res.image!));
      }
      if (res.cpu != null) {
        extras.add(OTel.attributeString('gcp_cloud_run.cpu', res.cpu!));
      }
      if (res.memory != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_run.memory',
          res.memory!,
        ));
      }
      if (res.minInstances != null) {
        extras.add(OTel.attributeInt(
          'gcp_cloud_run.min_instances',
          res.minInstances!,
        ));
      }
      if (res.maxInstances != null) {
        extras.add(OTel.attributeInt(
          'gcp_cloud_run.max_instances',
          res.maxInstances!,
        ));
      }
      if (res.concurrency != null) {
        extras.add(OTel.attributeInt(
          'gcp_cloud_run.concurrency',
          res.concurrency!,
        ));
      }
      if (res.timeoutSec != null) {
        extras.add(OTel.attributeInt(
          'gcp_cloud_run.timeout_sec',
          res.timeoutSec!,
        ));
      }
      if (res.executionEnvironment != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_run.execution_environment',
          res.executionEnvironment!,
        ));
      }
      if (res.startupCpuBoost != null) {
        extras.add(OTel.attributeBool(
          'gcp_cloud_run.startup_cpu_boost',
          res.startupCpuBoost!,
        ));
      }
      if (res.useHttp2 != null) {
        extras.add(OTel.attributeBool(
          'gcp_cloud_run.use_http2',
          res.useHttp2!,
        ));
      }
      if (res.invokerAuth != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_run.invoker_auth',
          res.invokerAuth!,
        ));
      }
      if (res.cloudSqlInstances != null) {
        extras.add(OTel.attributeStringList(
          'gcp_cloud_run.cloud_sql_instances',
          res.cloudSqlInstances!,
        ));
      }
      if (res.vpcConnector != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_run.vpc_connector',
          res.vpcConnector!,
        ));
      }
      if (res.jobName != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_run.job.name',
          res.jobName!,
        ));
      }
      if (res.executionName != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_run.execution.name',
          res.executionName!,
        ));
      }
      if (res.taskCount != null) {
        extras.add(OTel.attributeInt(
          'gcp_cloud_run.task.count',
          res.taskCount!,
        ));
      }
      if (res.parallelism != null) {
        extras.add(OTel.attributeInt(
          'gcp_cloud_run.parallelism',
          res.parallelism!,
        ));
      }
      if (res.executionStatus != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_run.execution.status',
          res.executionStatus!,
        ));
        if (res.executionStatus == 'FAILED' ||
            res.executionStatus == 'CANCELLED') {
          span.setStatus(
            SpanStatusCode.Error,
            'Cloud Run execution ${res.executionStatus}',
          );
        }
      }
      if (res.coldStart != null) {
        extras.add(OTel.attributeBool(
          'gcp_cloud_run.cold_start',
          res.coldStart!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_run.error.code',
          res.errorCode!,
        ));
        span.setStatus(SpanStatusCode.Error, 'Cloud Run ${res.errorCode}');
      }
      if (res.errorMessage != null) {
        extras.add(OTel.attributeString(
          'gcp_cloud_run.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Cloud Run HTTP ${res.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
