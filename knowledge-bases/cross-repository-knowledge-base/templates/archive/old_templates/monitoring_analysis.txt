Analyze the monitoring implementation and observability in the following code repository:

Repository: {repo_name}
File: {file_path}
Content:
{content}

Additional Context:
- Analysis Depth: {analysis_depth}
- Priority: {priority}
- Previous Analysis: {previous_analysis}
- Dependencies: {dependencies}
- Related Files: {related_files}
- Knowledge Base: {knowledge_base}

Please provide a comprehensive monitoring analysis, including:
1. Monitoring implementation
2. Monitoring gaps
3. Monitoring improvements
4. Monitoring patterns
5. Monitoring management

Format your response as a JSON object with the following structure:
{
    "status": "success",
    "timestamp": "YYYY-MM-DDTHH:MM:SS",
    "results": {
        "monitoring_implementation": {
            "total_metrics": 0,
            "coverage": 0.0,
            "quality": 0.0,
            "overall_score": 0.0
        },
        "monitoring_components": [
            {
                "component": "component_name",
                "type": "metric_type",
                "implementation": "implementation_strategy",
                "quality": 0.0,
                "issues": ["issue1", "issue2"]
            }
        ],
        "monitoring_gaps": [
            {
                "type": "metrics|alerts|dashboards|collection|analysis",
                "description": "gap_description",
                "component": "component_name",
                "severity": "low|medium|high|critical",
                "impact": "impact_description",
                "fix": "fix_suggestion"
            }
        ],
        "improvements": [
            {
                "type": "metrics|alerts|dashboards|collection|analysis",
                "description": "improvement_description",
                "priority": "low|medium|high",
                "implementation": "implementation_suggestion",
                "benefit": "benefit_description"
            }
        ],
        "patterns": [
            {
                "pattern": "pattern_name",
                "description": "pattern_description",
                "examples": ["example1", "example2"],
                "recommendation": "recommendation_text"
            }
        ],
        "monitoring_management": {
            "systems": [
                {
                    "type": "system_type",
                    "effectiveness": 0.0,
                    "implementation": "implementation_details",
                    "quality": 0.0
                }
            ],
            "coverage": {
                "total_systems": 0,
                "effective_systems": 0,
                "coverage_score": 0.0
            }
        },
        "monitoring_health": [
            {
                "component": "component_name",
                "status": "healthy|degraded|unhealthy",
                "metrics": {
                    "coverage_score": 0.0,
                    "reliability_score": 0.0,
                    "quality": 0.0
                },
                "issues": ["issue1", "issue2"]
            }
        ],
        "issues": [
            {
                "type": "metrics|alerts|dashboards|collection|analysis",
                "description": "issue_description",
                "location": "file_path:line_number",
                "severity": "low|medium|high",
                "fix": "fix_suggestion"
            }
        ],
        "metrics": {
            "total_metrics": 0,
            "active_metrics": 0,
            "coverage_score": 0.0,
            "monitoring_quality_score": 0.0,
            "overall_monitoring_score": 0.0
        }
    }
} 