Analyze the performance characteristics and optimization opportunities in the following code repository:

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

Please provide a comprehensive performance analysis, including:
1. Performance implementation
2. Performance bottlenecks
3. Performance improvements
4. Performance patterns
5. Performance management

Format your response as a JSON object with the following structure:
{
    "status": "success",
    "timestamp": "YYYY-MM-DDTHH:MM:SS",
    "results": {
        "performance_implementation": {
            "total_operations": 0,
            "efficiency": 0.0,
            "quality": 0.0,
            "overall_score": 0.0
        },
        "performance_components": [
            {
                "component": "component_name",
                "type": "operation_type",
                "implementation": "implementation_strategy",
                "quality": 0.0,
                "issues": ["issue1", "issue2"]
            }
        ],
        "performance_bottlenecks": [
            {
                "type": "cpu|memory|io|network|database",
                "description": "bottleneck_description",
                "component": "component_name",
                "severity": "low|medium|high|critical",
                "impact": "impact_description",
                "fix": "fix_suggestion"
            }
        ],
        "improvements": [
            {
                "type": "cpu|memory|io|network|database",
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
        "performance_management": {
            "optimizations": [
                {
                    "type": "optimization_type",
                    "effectiveness": 0.0,
                    "implementation": "implementation_details",
                    "quality": 0.0
                }
            ],
            "coverage": {
                "total_optimizations": 0,
                "effective_optimizations": 0,
                "coverage_score": 0.0
            }
        },
        "performance_health": [
            {
                "component": "component_name",
                "status": "healthy|degraded|unhealthy",
                "metrics": {
                    "efficiency_score": 0.0,
                    "resource_usage": 0.0,
                    "quality": 0.0
                },
                "issues": ["issue1", "issue2"]
            }
        ],
        "issues": [
            {
                "type": "cpu|memory|io|network|database",
                "description": "issue_description",
                "location": "file_path:line_number",
                "severity": "low|medium|high",
                "fix": "fix_suggestion"
            }
        ],
        "metrics": {
            "total_operations": 0,
            "bottleneck_count": 0,
            "efficiency_score": 0.0,
            "performance_quality_score": 0.0,
            "overall_performance_score": 0.0
        }
    }
}

Please provide your analysis in a clear, structured JSON format that can be easily parsed and processed by automated tools. 