Analyze the microservices implementation in the following code repository:

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

Please provide a comprehensive analysis of the microservices implementation, including:
1. Service boundaries
2. Service communication
3. Service improvements
4. Service patterns
5. Service security

Format your response as a JSON object with the following structure:
{
    "status": "success",
    "timestamp": "YYYY-MM-DDTHH:MM:SS",
    "results": {
        "microservices_implementation": {
            "total_services": 0,
            "coverage": 0.0,
            "quality": 0.0,
            "overall_score": 0.0
        },
        "service_boundaries": [
            {
                "service": "service_name",
                "responsibilities": ["responsibility1", "responsibility2"],
                "dependencies": ["dependency1", "dependency2"],
                "cohesion": 0.0,
                "coupling": 0.0
            }
        ],
        "service_communication": [
            {
                "type": "communication_type",
                "protocol": "protocol_name",
                "services": ["service1", "service2"],
                "quality": 0.0,
                "issues": ["issue1", "issue2"]
            }
        ],
        "improvements": [
            {
                "type": "boundary|communication|performance|security",
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
            "authentication": {
                "type": "auth_type",
                "coverage": 0.0,
                "issues": ["issue1", "issue2"]
            },
            "authorization": {
                "type": "authz_type",
                "coverage": 0.0,
                "issues": ["issue1", "issue2"]
            },
            "vulnerabilities": [
                {
                    "type": "vulnerability_type",
                    "description": "vulnerability_description",
                    "severity": "low|medium|high|critical",
                    "mitigation": "mitigation_suggestion"
                }
            ]
        },
        "service_health": [
            {
                "service": "service_name",
                "status": "healthy|degraded|unhealthy",
                "metrics": {
                    "availability": 0.0,
                    "latency": 0.0,
                    "error_rate": 0.0
                },
                "issues": ["issue1", "issue2"]
            }
        ],
        "issues": [
            {
                "type": "boundary|communication|performance|security",
                "description": "issue_description",
                "location": "file_path:line_number",
                "severity": "low|medium|high",
                "fix": "fix_suggestion"
            }
        ],
        "metrics": {
            "total_services": 0,
            "healthy_services": 0,
            "security_score": 0.0,
            "performance_score": 0.0,
            "microservices_quality_score": 0.0
        }
    }
} 