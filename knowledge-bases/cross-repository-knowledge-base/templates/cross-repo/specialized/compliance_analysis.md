Analyze the compliance implementation in the following code repository:

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

Please provide a comprehensive analysis of the compliance implementation, including:
1. Regulatory compliance
2. Compliance issues
3. Compliance improvements
4. Compliance patterns
5. Audit requirements

Format your response as a JSON object with the following structure:
{
    "status": "success",
    "timestamp": "YYYY-MM-DDTHH:MM:SS",
    "results": {
        "compliance_implementation": {
            "standards": ["standard1", "standard2"],
            "coverage": 0.0,
            "quality": 0.0,
            "overall_score": 0.0
        },
        "regulatory_compliance": [
            {
                "regulation": "regulation_name",
                "version": "version_number",
                "status": "compliant|partial|non_compliant",
                "requirements": ["requirement1", "requirement2"],
                "coverage": 0.0
            }
        ],
        "compliance_issues": [
            {
                "type": "violation|gap|risk",
                "description": "issue_description",
                "regulation": "regulation_name",
                "severity": "low|medium|high|critical",
                "impact": "impact_description",
                "fix": "fix_suggestion"
            }
        ],
        "improvements": [
            {
                "type": "compliance|documentation|process",
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
        "audit_requirements": {
            "internal": {
                "frequency": "frequency_details",
                "scope": "scope_details",
                "requirements": ["requirement1", "requirement2"]
            },
            "external": {
                "frequency": "frequency_details",
                "scope": "scope_details",
                "requirements": ["requirement1", "requirement2"]
            }
        },
        "documentation": {
            "policies": [
                {
                    "name": "policy_name",
                    "type": "policy_type",
                    "status": "current|outdated|missing",
                    "coverage": 0.0
                }
            ],
            "procedures": [
                {
                    "name": "procedure_name",
                    "type": "procedure_type",
                    "status": "current|outdated|missing",
                    "coverage": 0.0
                }
            ]
        },
        "issues": [
            {
                "type": "compliance|documentation|process",
                "description": "issue_description",
                "location": "file_path:line_number",
                "severity": "low|medium|high",
                "fix": "fix_suggestion"
            }
        ],
        "metrics": {
            "total_requirements": 0,
            "compliant_requirements": 0,
            "documentation_coverage": 0.0,
            "audit_readiness": 0.0,
            "compliance_score": 0.0
        }
    }
} 