Analyze the logging implementation in the following code repository:

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

Please provide a comprehensive analysis of the logging implementation, including:
1. Logging implementation
2. Logging gaps
3. Logging improvements
4. Logging patterns
5. Log management

Format your response as a JSON object with the following structure:
{
    "status": "success",
    "timestamp": "YYYY-MM-DDTHH:MM:SS",
    "results": {
        "logging_implementation": {
            "total_logs": 0,
            "coverage": 0.0,
            "quality": 0.0,
            "overall_score": 0.0
        },
        "log_types": [
            {
                "type": "log_type",
                "level": "log_level",
                "format": "log_format",
                "quality": 0.0,
                "issues": ["issue1", "issue2"]
            }
        ],
        "logging_gaps": [
            {
                "type": "coverage|quality|security|performance",
                "description": "gap_description",
                "component": "component_name",
                "severity": "low|medium|high|critical",
                "impact": "impact_description",
                "fix": "fix_suggestion"
            }
        ],
        "improvements": [
            {
                "type": "coverage|quality|security|performance",
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
        "log_management": {
            "storage": {
                "type": "storage_type",
                "retention": "retention_period",
                "compression": "compression_method",
                "quality": 0.0
            },
            "rotation": {
                "strategy": "rotation_strategy",
                "frequency": "rotation_frequency",
                "max_size": "max_size",
                "quality": 0.0
            },
            "search": {
                "capabilities": ["capability1", "capability2"],
                "performance": 0.0,
                "quality": 0.0
            }
        },
        "logging_health": [
            {
                "component": "component_name",
                "status": "healthy|degraded|unhealthy",
                "metrics": {
                    "log_rate": 0.0,
                    "error_rate": 0.0,
                    "quality": 0.0
                },
                "issues": ["issue1", "issue2"]
            }
        ],
        "issues": [
            {
                "type": "coverage|quality|security|performance",
                "description": "issue_description",
                "location": "file_path:line_number",
                "severity": "low|medium|high",
                "fix": "fix_suggestion"
            }
        ],
        "metrics": {
            "total_logs": 0,
            "error_logs": 0,
            "log_coverage": 0.0,
            "logging_quality_score": 0.0,
            "overall_logging_score": 0.0
        }
    }
} 