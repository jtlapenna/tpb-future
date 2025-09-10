Analyze the cursor rules implementation and compliance in the following code repository:

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
- Cursor Rules: {cursor_rules}

Please provide a comprehensive analysis of the cursor rules implementation, including:
1. Rules compliance
2. Rules coverage
3. Rules effectiveness
4. Rules patterns
5. Rules management

Format your response as a JSON object with the following structure:
{
    "status": "success",
    "timestamp": "YYYY-MM-DDTHH:MM:SS",
    "results": {
        "cursor_rules_implementation": {
            "total_rules": 0,
            "coverage": 0.0,
            "quality": 0.0,
            "overall_score": 0.0
        },
        "rule_components": [
            {
                "component": "component_name",
                "type": "rule_type",
                "implementation": "implementation_strategy",
                "quality": 0.0,
                "issues": ["issue1", "issue2"]
            }
        ],
        "rule_compliance": [
            {
                "rule": "rule_name",
                "type": "rule_type",
                "status": "compliant|partial|non_compliant",
                "coverage": 0.0,
                "issues": ["issue1", "issue2"]
            }
        ],
        "rule_coverage": [
            {
                "area": "area_name",
                "rules_applied": 0,
                "total_rules": 0,
                "coverage_score": 0.0,
                "missing_rules": ["rule1", "rule2"]
            }
        ],
        "rule_effectiveness": [
            {
                "rule": "rule_name",
                "effectiveness": 0.0,
                "implementation": "implementation_details",
                "quality": 0.0,
                "improvements": ["improvement1", "improvement2"]
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
        "rule_management": {
            "categories": [
                {
                    "category": "category_name",
                    "rules_count": 0,
                    "coverage": 0.0,
                    "quality": 0.0
                }
            ],
            "coverage": {
                "total_categories": 0,
                "covered_categories": 0,
                "coverage_score": 0.0
            }
        },
        "rule_health": [
            {
                "component": "component_name",
                "status": "healthy|degraded|unhealthy",
                "metrics": {
                    "compliance_score": 0.0,
                    "coverage_score": 0.0,
                    "quality": 0.0
                },
                "issues": ["issue1", "issue2"]
            }
        ],
        "issues": [
            {
                "type": "compliance|coverage|effectiveness|implementation",
                "description": "issue_description",
                "location": "file_path:line_number",
                "severity": "low|medium|high",
                "fix": "fix_suggestion"
            }
        ],
        "metrics": {
            "total_rules": 0,
            "compliant_rules": 0,
            "coverage_score": 0.0,
            "rule_quality_score": 0.0,
            "overall_rules_score": 0.0
        }
    }
} 