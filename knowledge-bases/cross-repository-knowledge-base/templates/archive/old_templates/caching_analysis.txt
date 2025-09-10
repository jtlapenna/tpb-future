Analyze the caching implementation and optimization in the following code repository:

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

Please provide a comprehensive caching analysis, including:
1. Caching implementation
2. Caching gaps
3. Caching improvements
4. Caching patterns
5. Caching management

Format your response as a JSON object with the following structure:
{
    "status": "success",
    "timestamp": "YYYY-MM-DDTHH:MM:SS",
    "results": {
        "caching_implementation": {
            "total_cache_items": 0,
            "coverage": 0.0,
            "quality": 0.0,
            "overall_score": 0.0
        },
        "caching_components": [
            {
                "component": "component_name",
                "type": "cache_type",
                "implementation": "implementation_strategy",
                "quality": 0.0,
                "issues": ["issue1", "issue2"]
            }
        ],
        "caching_gaps": [
            {
                "type": "invalidation|coherence|performance|memory|distribution",
                "description": "gap_description",
                "component": "component_name",
                "severity": "low|medium|high|critical",
                "impact": "impact_description",
                "fix": "fix_suggestion"
            }
        ],
        "improvements": [
            {
                "type": "invalidation|coherence|performance|memory|distribution",
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
        "caching_management": {
            "strategies": [
                {
                    "type": "strategy_type",
                    "effectiveness": 0.0,
                    "implementation": "implementation_details",
                    "quality": 0.0
                }
            ],
            "coverage": {
                "total_strategies": 0,
                "effective_strategies": 0,
                "coverage_score": 0.0
            }
        },
        "caching_health": [
            {
                "component": "component_name",
                "status": "healthy|degraded|unhealthy",
                "metrics": {
                    "hit_rate": 0.0,
                    "performance_score": 0.0,
                    "quality": 0.0
                },
                "issues": ["issue1", "issue2"]
            }
        ],
        "issues": [
            {
                "type": "invalidation|coherence|performance|memory|distribution",
                "description": "issue_description",
                "location": "file_path:line_number",
                "severity": "low|medium|high",
                "fix": "fix_suggestion"
            }
        ],
        "metrics": {
            "total_cache_items": 0,
            "active_cache_items": 0,
            "hit_rate": 0.0,
            "caching_quality_score": 0.0,
            "overall_caching_score": 0.0
        }
    }
} 