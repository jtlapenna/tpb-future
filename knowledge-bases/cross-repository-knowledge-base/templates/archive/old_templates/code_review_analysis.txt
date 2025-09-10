Analyze the code quality and implementation in the following code repository:

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

Please provide a comprehensive code review analysis, including:
1. Code quality implementation
2. Code review findings
3. Code improvements
4. Code patterns
5. Code management

Format your response as a JSON object with the following structure:
{
    "status": "success",
    "timestamp": "YYYY-MM-DDTHH:MM:SS",
    "results": {
        "code_quality_implementation": {
            "total_lines": 0,
            "complexity": 0.0,
            "maintainability": 0.0,
            "overall_score": 0.0
        },
        "code_components": [
            {
                "component": "component_name",
                "type": "component_type",
                "quality": 0.0,
                "complexity": 0.0,
                "issues": ["issue1", "issue2"]
            }
        ],
        "code_review_findings": [
            {
                "type": "style|design|performance|security|maintainability",
                "description": "finding_description",
                "component": "component_name",
                "severity": "low|medium|high|critical",
                "impact": "impact_description",
                "fix": "fix_suggestion"
            }
        ],
        "improvements": [
            {
                "type": "style|design|performance|security|maintainability",
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
        "code_management": {
            "standards": [
                {
                    "type": "standard_type",
                    "compliance": 0.0,
                    "implementation": "implementation_details",
                    "quality": 0.0
                }
            ],
            "coverage": {
                "total_standards": 0,
                "compliant_standards": 0,
                "compliance_score": 0.0
            }
        },
        "code_health": [
            {
                "component": "component_name",
                "status": "healthy|degraded|unhealthy",
                "metrics": {
                    "complexity_score": 0.0,
                    "maintainability_score": 0.0,
                    "quality": 0.0
                },
                "issues": ["issue1", "issue2"]
            }
        ],
        "issues": [
            {
                "type": "style|design|performance|security|maintainability",
                "description": "issue_description",
                "location": "file_path:line_number",
                "severity": "low|medium|high",
                "fix": "fix_suggestion"
            }
        ],
        "metrics": {
            "total_lines": 0,
            "complexity_score": 0.0,
            "maintainability_score": 0.0,
            "code_quality_score": 0.0,
            "overall_code_score": 0.0
        }
    }
} 