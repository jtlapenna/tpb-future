Analyze the mobile implementation and platform support in the following code repository:

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

Please provide a comprehensive mobile analysis, including:
1. Mobile implementation
2. Mobile gaps
3. Mobile improvements
4. Mobile patterns
5. Mobile management

Format your response as a JSON object with the following structure:
{
    "status": "success",
    "timestamp": "YYYY-MM-DDTHH:MM:SS",
    "results": {
        "mobile_implementation": {
            "total_components": 0,
            "coverage": 0.0,
            "quality": 0.0,
            "overall_score": 0.0
        },
        "mobile_components": [
            {
                "component": "component_name",
                "type": "component_type",
                "implementation": "implementation_strategy",
                "quality": 0.0,
                "issues": ["issue1", "issue2"]
            }
        ],
        "mobile_gaps": [
            {
                "type": "ui|performance|platform|device|network",
                "description": "gap_description",
                "component": "component_name",
                "severity": "low|medium|high|critical",
                "impact": "impact_description",
                "fix": "fix_suggestion"
            }
        ],
        "improvements": [
            {
                "type": "ui|performance|platform|device|network",
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
        "mobile_management": {
            "platforms": [
                {
                    "type": "platform_type",
                    "support": 0.0,
                    "implementation": "implementation_details",
                    "quality": 0.0
                }
            ],
            "coverage": {
                "total_platforms": 0,
                "supported_platforms": 0,
                "coverage_score": 0.0
            }
        },
        "mobile_health": [
            {
                "component": "component_name",
                "status": "healthy|degraded|unhealthy",
                "metrics": {
                    "performance_score": 0.0,
                    "compatibility_score": 0.0,
                    "quality": 0.0
                },
                "issues": ["issue1", "issue2"]
            }
        ],
        "issues": [
            {
                "type": "ui|performance|platform|device|network",
                "description": "issue_description",
                "location": "file_path:line_number",
                "severity": "low|medium|high",
                "fix": "fix_suggestion"
            }
        ],
        "metrics": {
            "total_components": 0,
            "platform_support": 0,
            "performance_score": 0.0,
            "mobile_quality_score": 0.0,
            "overall_mobile_score": 0.0
        }
    }
} 