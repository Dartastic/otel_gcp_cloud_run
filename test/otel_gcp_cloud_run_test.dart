// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_gcp_cloud_run/otel_gcp_cloud_run.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_gcp_cloud_run-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('services.update records traffic split + cpu + memory', () async {
    await tracedGcpCloudRun<String>(
      operation: 'services.update',
      invoke: () async => const GcpCloudRunCallResult(
        value: 'ok',
        result: GcpCloudRunResult(
          project: 'p1',
          region: 'us-central1',
          resourceKind: 'service',
          serviceName: 'web',
          revision: 'web-00042-xyz',
          trafficSplit: 'web-00042-xyz=90,web-00041-abc=10',
          image: 'us-docker.pkg.dev/p1/web:abc',
          cpu: '2',
          memory: '1Gi',
          minInstances: 1,
          maxInstances: 50,
          concurrency: 80,
          executionEnvironment: 'gen2',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('gcp_cloud_run services.update')!);
    expect(a['gcp_cloud_run.execution_environment'], 'gen2');
    expect(a['gcp_cloud_run.concurrency'], 80);
  });

  test('invoke.https records cold start', () async {
    await tracedGcpCloudRun<String>(
      operation: 'invoke.https',
      invoke: () async => const GcpCloudRunCallResult(
        value: 'ok',
        result: GcpCloudRunResult(
          serviceName: 'web',
          coldStart: true,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('gcp_cloud_run invoke.https')!);
    expect(a['gcp_cloud_run.cold_start'], true);
  });

  test('jobs.run FAILED execution sets span error', () async {
    await tracedGcpCloudRun<String>(
      operation: 'jobs.run',
      invoke: () async => const GcpCloudRunCallResult(
        value: 'ok',
        result: GcpCloudRunResult(
          resourceKind: 'job',
          jobName: 'nightly',
          executionName: 'nightly-2026-05-15',
          taskCount: 10,
          parallelism: 5,
          executionStatus: 'FAILED',
        ),
      ),
    );
    expect(
      spans.findSpanByName('gcp_cloud_run jobs.run')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutGcpCloudRunInstrumentationAsync(() async {
      await tracedGcpCloudRun<String>(
        operation: 'services.list',
        invoke: () async => const GcpCloudRunCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('gcp_cloud_run '), isEmpty);
  });
}
