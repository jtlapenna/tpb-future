Analyze the database implementation and management in the following code repository:

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

Please provide a comprehensive database analysis, including:
1. Database implementation
2. Database gaps
3. Database improvements
4. Database patterns
5. Database management

Format your response as a JSON object with the following structure:
{
    "status": "success",
    "timestamp": "YYYY-MM-DDTHH:MM:SS",
    "results": {
        "database_implementation": {
            "total_tables": 0,
            "coverage": 0.0,
            "quality": 0.0,
            "overall_score": 0.0
        },
        "database_components": [
            {
                "component": "component_name",
                "type": "table_type",
                "implementation": "implementation_strategy",
                "quality": 0.0,
                "issues": ["issue1", "issue2"]
            }
        ],
        "database_gaps": [
            {
                "type": "schema|performance|security|replication|backup",
                "description": "gap_description",
                "component": "component_name",
                "severity": "low|medium|high|critical",
                "impact": "impact_description",
                "fix": "fix_suggestion"
            }
        ],
        "improvements": [
            {
                "type": "schema|performance|security|replication|backup",
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
        "database_management": {
            "tables": [
                {
                    "type": "table_type",
                    "effectiveness": 0.0,
                    "implementation": "implementation_details",
                    "quality": 0.0
                }
            ],
            "coverage": {
                "total_tables": 0,
                "effective_tables": 0,
                "coverage_score": 0.0
            }
        },
        "database_health": [
            {
                "component": "component_name",
                "status": "healthy|degraded|unhealthy",
                "metrics": {
                    "performance_score": 0.0,
                    "reliability_score": 0.0,
                    "quality": 0.0
                },
                "issues": ["issue1", "issue2"]
            }
        ],
        "issues": [
            {
                "type": "schema|performance|security|replication|backup",
                "description": "issue_description",
                "location": "file_path:line_number",
                "severity": "low|medium|high",
                "fix": "fix_suggestion"
            }
        ],
        "metrics": {
            "total_tables": 0,
            "active_tables": 0,
            "performance_score": 0.0,
            "database_quality_score": 0.0,
            "overall_database_score": 0.0
        }
    }
} 