Analyze the test coverage in the following code repository:

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

Please provide a comprehensive analysis of the test coverage, including:
1. Test coverage and quality
2. Untested code paths
3. Test improvements
4. Test patterns and anti-patterns
5. Test performance

Format your response as a JSON object with the following structure:
{
    "status": "success",
    "timestamp": "YYYY-MM-DDTHH:MM:SS",
    "results": {
        "coverage_metrics": {
            "line_coverage": 0.0,
            "branch_coverage": 0.0,
            "function_coverage": 0.0,
            "statement_coverage": 0.0,
            "overall_coverage": 0.0
        },
        "untested_code": [
            {
                "file": "file_path",
                "line": "line_number",
                "type": "function|class|method",
                "description": "code_description",
                "risk_level": "low|medium|high"
            }
        ],
        "test_quality": [
            {
                "aspect": "readability|maintainability|reliability",
                "score": 0.0,
                "issues": [
                    {
                        "description": "issue_description",
                        "severity": "low|medium|high",
                        "suggestion": "improvement_suggestion"
                    }
                ]
            }
        ],
        "test_patterns": [
            {
                "pattern": "pattern_name",
                "description": "pattern_description",
                "examples": ["example1", "example2"],
                "recommendation": "recommendation_text"
            }
        ],
        "test_anti_patterns": [
            {
                "pattern": "anti_pattern_name",
                "description": "anti_pattern_description",
                "examples": ["example1", "example2"],
                "impact": "low|medium|high",
                "fix": "fix_suggestion"
            }
        ],
        "performance_metrics": {
            "test_execution_time": 0.0,
            "test_setup_time": 0.0,
            "test_teardown_time": 0.0,
            "average_test_duration": 0.0,
            "slow_tests": [
                {
                    "test_name": "test_name",
                    "duration": 0.0,
                    "suggestion": "optimization_suggestion"
                }
            ]
        },
        "improvements": [
            {
                "type": "coverage|quality|performance",
                "description": "improvement_description",
                "priority": "low|medium|high",
                "implementation": "implementation_suggestion"
            }
        ],
        "metrics": {
            "total_tests": 0,
            "failing_tests": 0,
            "slow_tests": 0,
            "untested_lines": 0,
            "test_quality_score": 0.0
        }
    }
} 