Analyze the cross-platform implementation in the following code repository:

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

Please provide a comprehensive analysis of the cross-platform implementation, including:
1. Platform compatibility
2. Platform-specific issues
3. Platform improvements
4. Platform patterns
5. Platform security

Format your response as a JSON object with the following structure:
{
    "status": "success",
    "timestamp": "YYYY-MM-DDTHH:MM:SS",
    "results": {
        "cross_platform_implementation": {
            "platforms": ["platform1", "platform2"],
            "coverage": 0.0,
            "quality": 0.0,
            "overall_score": 0.0
        },
        "platform_compatibility": [
            {
                "platform": "platform_name",
                "version": "version_number",
                "compatibility": "compatible|partial|incompatible",
                "issues": ["issue1", "issue2"],
                "coverage": 0.0
            }
        ],
        "platform_specific_issues": [
            {
                "type": "compatibility|performance|security",
                "description": "issue_description",
                "platform": "platform_name",
                "severity": "low|medium|high|critical",
                "impact": "impact_description",
                "fix": "fix_suggestion"
            }
        ],
        "improvements": [
            {
                "type": "compatibility|performance|security",
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
        "security": {
            "platform_specific": [
                {
                    "platform": "platform_name",
                    "vulnerabilities": [
                        {
                            "type": "vulnerability_type",
                            "description": "vulnerability_description",
                            "severity": "low|medium|high|critical",
                            "mitigation": "mitigation_suggestion"
                        }
                    ]
                }
            ],
            "common": [
                {
                    "type": "vulnerability_type",
                    "description": "vulnerability_description",
                    "severity": "low|medium|high|critical",
                    "mitigation": "mitigation_suggestion"
                }
            ]
        },
        "platform_features": [
            {
                "feature": "feature_name",
                "platforms": ["platform1", "platform2"],
                "implementation": "implementation_details",
                "quality": 0.0
            }
        ],
        "issues": [
            {
                "type": "compatibility|performance|security",
                "description": "issue_description",
                "location": "file_path:line_number",
                "severity": "low|medium|high",
                "fix": "fix_suggestion"
            }
        ],
        "metrics": {
            "total_platforms": 0,
            "compatible_platforms": 0,
            "security_score": 0.0,
            "performance_score": 0.0,
            "cross_platform_quality_score": 0.0
        }
    }
} 