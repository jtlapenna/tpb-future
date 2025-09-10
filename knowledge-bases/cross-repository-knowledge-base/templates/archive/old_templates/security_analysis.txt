You are an expert security analyst specializing in code security and vulnerability assessment. Your task is to analyze the security aspects of the following code and identify potential vulnerabilities and security improvements.

Repository: {repo_name}
File: {file_path}

Code Content:
{content}

Additional Metadata:
{metadata}

Additional Context:
- Analysis Depth: {analysis_depth}
- Priority: {priority}
- Previous Analysis: {previous_analysis}
- Dependencies: {dependencies}
- Related Files: {related_files}
- Knowledge Base: {knowledge_base}

Please provide a comprehensive security analysis, including:
1. Security implementation
2. Security vulnerabilities
3. Security improvements
4. Security patterns
5. Security management

Format your response as a JSON object with the following structure:
{
    "status": "success",
    "timestamp": "YYYY-MM-DDTHH:MM:SS",
    "results": {
        "security_implementation": {
            "total_controls": 0,
            "coverage": 0.0,
            "quality": 0.0,
            "overall_score": 0.0
        },
        "security_components": [
            {
                "component": "component_name",
                "type": "security_control_type",
                "implementation": "implementation_strategy",
                "quality": 0.0,
                "issues": ["issue1", "issue2"]
            }
        ],
        "security_vulnerabilities": [
            {
                "type": "authentication|authorization|data_protection|input_validation|cryptography",
                "description": "vulnerability_description",
                "component": "component_name",
                "severity": "low|medium|high|critical",
                "impact": "impact_description",
                "fix": "fix_suggestion"
            }
        ],
        "improvements": [
            {
                "type": "authentication|authorization|data_protection|input_validation|cryptography",
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
        "security_management": {
            "controls": [
                {
                    "type": "control_type",
                    "effectiveness": 0.0,
                    "implementation": "implementation_details",
                    "quality": 0.0
                }
            ],
            "coverage": {
                "total_controls": 0,
                "effective_controls": 0,
                "coverage_score": 0.0
            }
        },
        "security_health": [
            {
                "component": "component_name",
                "status": "healthy|degraded|unhealthy",
                "metrics": {
                    "protection_score": 0.0,
                    "compliance_score": 0.0,
                    "quality": 0.0
                },
                "issues": ["issue1", "issue2"]
            }
        ],
        "issues": [
            {
                "type": "authentication|authorization|data_protection|input_validation|cryptography",
                "description": "issue_description",
                "location": "file_path:line_number",
                "severity": "low|medium|high",
                "fix": "fix_suggestion"
            }
        ],
        "metrics": {
            "total_controls": 0,
            "vulnerability_count": 0,
            "protection_score": 0.0,
            "security_quality_score": 0.0,
            "overall_security_score": 0.0
        }
    }
}

Please provide your analysis in a clear, structured JSON format that can be easily parsed and processed by automated tools. 