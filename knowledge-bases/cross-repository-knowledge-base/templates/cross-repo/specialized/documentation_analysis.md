Analyze the documentation in the following code repository:

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

Please provide a comprehensive analysis of the documentation, including:
1. Documentation quality
2. Missing documentation
3. Documentation improvements
4. Documentation patterns
5. API documentation completeness

Format your response as a JSON object with the following structure:
{
    "status": "success",
    "timestamp": "YYYY-MM-DDTHH:MM:SS",
    "results": {
        "documentation_quality": {
            "completeness": 0.0,
            "accuracy": 0.0,
            "clarity": 0.0,
            "consistency": 0.0,
            "overall_score": 0.0
        },
        "missing_documentation": [
            {
                "type": "function|class|method|api|parameter",
                "name": "item_name",
                "location": "file_path:line_number",
                "severity": "low|medium|high",
                "suggestion": "documentation_suggestion"
            }
        ],
        "improvements": [
            {
                "type": "completeness|accuracy|clarity|consistency",
                "description": "improvement_description",
                "priority": "low|medium|high",
                "implementation": "implementation_suggestion"
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
        "api_documentation": {
            "endpoints_documented": 0,
            "total_endpoints": 0,
            "parameters_documented": 0,
            "total_parameters": 0,
            "responses_documented": 0,
            "total_responses": 0,
            "examples_provided": 0,
            "total_examples_needed": 0,
            "completeness_score": 0.0
        },
        "code_documentation": {
            "functions_documented": 0,
            "total_functions": 0,
            "classes_documented": 0,
            "total_classes": 0,
            "methods_documented": 0,
            "total_methods": 0,
            "parameters_documented": 0,
            "total_parameters": 0,
            "completeness_score": 0.0
        },
        "issues": [
            {
                "type": "incomplete|outdated|incorrect|unclear",
                "description": "issue_description",
                "location": "file_path:line_number",
                "severity": "low|medium|high",
                "fix": "fix_suggestion"
            }
        ],
        "metrics": {
            "total_documented_items": 0,
            "total_items": 0,
            "documentation_coverage": 0.0,
            "documentation_quality_score": 0.0,
            "improvement_opportunities": 0
        }
    }
} 