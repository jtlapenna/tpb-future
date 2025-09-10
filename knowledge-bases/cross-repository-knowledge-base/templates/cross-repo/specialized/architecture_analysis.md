Analyze the architectural design and implementation in the following code repository:

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

Please provide a comprehensive architecture analysis, including:
1. Architecture implementation
2. Architecture gaps
3. Architecture improvements
4. Architecture patterns
5. Architecture management

Format your response as a JSON object with the following structure:
{
    "status": "success",
    "timestamp": "YYYY-MM-DDTHH:MM:SS",
    "results": {
        "architecture_implementation": {
            "total_components": 0,
            "coverage": 0.0,
            "quality": 0.0,
            "overall_score": 0.0
        },
        "architecture_components": [
            {
                "component": "component_name",
                "type": "component_type",
                "responsibility": "responsibility_description",
                "quality": 0.0,
                "issues": ["issue1", "issue2"]
            }
        ],
        "architecture_gaps": [
            {
                "type": "design|scalability|maintainability|security|performance",
                "description": "gap_description",
                "component": "component_name",
                "severity": "low|medium|high|critical",
                "impact": "impact_description",
                "fix": "fix_suggestion"
            }
        ],
        "improvements": [
            {
                "type": "design|scalability|maintainability|security|performance",
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
        "architecture_management": {
            "principles": [
                {
                    "type": "principle_type",
                    "adherence": 0.0,
                    "implementation": "implementation_details",
                    "quality": 0.0
                }
            ],
            "coverage": {
                "total_principles": 0,
                "adherent_principles": 0,
                "adherence_score": 0.0
            }
        },
        "architecture_health": [
            {
                "component": "component_name",
                "status": "healthy|degraded|unhealthy",
                "metrics": {
                    "cohesion_score": 0.0,
                    "coupling_score": 0.0,
                    "quality": 0.0
                },
                "issues": ["issue1", "issue2"]
            }
        ],
        "issues": [
            {
                "type": "design|scalability|maintainability|security|performance",
                "description": "issue_description",
                "location": "file_path:line_number",
                "severity": "low|medium|high",
                "fix": "fix_suggestion"
            }
        ],
        "metrics": {
            "total_components": 0,
            "cohesion_score": 0.0,
            "coupling_score": 0.0,
            "architecture_quality_score": 0.0,
            "overall_architecture_score": 0.0
        }
    }
} 