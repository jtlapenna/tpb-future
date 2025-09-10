Analyze the error handling implementation in the following code repository:

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

Please provide a comprehensive analysis of the error handling implementation, including:
1. Error handling implementation
2. Error handling gaps
3. Error handling improvements
4. Error handling patterns
5. Error management

Format your response as a JSON object with the following structure:
{
    "status": "success",
    "timestamp": "YYYY-MM-DDTHH:MM:SS",
    "results": {
        "error_handling_implementation": {
            "total_handlers": 0,
            "coverage": 0.0,
            "quality": 0.0,
            "overall_score": 0.0
        },
        "error_types": [
            {
                "type": "error_type",
                "handling": "handling_strategy",
                "recovery": "recovery_method",
                "quality": 0.0,
                "issues": ["issue1", "issue2"]
            }
        ],
        "error_handling_gaps": [
            {
                "type": "coverage|quality|recovery|logging",
                "description": "gap_description",
                "component": "component_name",
                "severity": "low|medium|high|critical",
                "impact": "impact_description",
                "fix": "fix_suggestion"
            }
        ],
        "improvements": [
            {
                "type": "coverage|quality|recovery|logging",
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
        "error_management": {
            "handlers": [
                {
                    "type": "handler_type",
                    "effectiveness": 0.0,
                    "implementation": "implementation_details",
                    "quality": 0.0
                }
            ],
            "coverage": {
                "total_handlers": 0,
                "effective_handlers": 0,
                "coverage_score": 0.0
            }
        },
        "error_health": [
            {
                "component": "component_name",
                "status": "healthy|degraded|unhealthy",
                "metrics": {
                    "recovery_rate": 0.0,
                    "logging_rate": 0.0,
                    "quality": 0.0
                },
                "issues": ["issue1", "issue2"]
            }
        ],
        "issues": [
            {
                "type": "coverage|quality|recovery|logging",
                "description": "issue_description",
                "location": "file_path:line_number",
                "severity": "low|medium|high",
                "fix": "fix_suggestion"
            }
        ],
        "metrics": {
            "total_errors": 0,
            "handled_errors": 0,
            "recovery_rate": 0.0,
            "error_handling_quality_score": 0.0,
            "overall_error_handling_score": 0.0
        }
    }
} 