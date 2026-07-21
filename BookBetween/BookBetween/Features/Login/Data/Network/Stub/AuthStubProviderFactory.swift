//
//  AuthStubProviderFactory.swift
//  BookBetween
//

import Moya

enum AuthStubProviderFactory {
    static func make(
        scenario: AuthStubScenario
    ) -> MoyaProvider<AuthTarget> {
        let endpointClosure: (AuthTarget) -> Endpoint = { target in
            let endpoint = MoyaProvider<AuthTarget>.defaultEndpointMapping(
                for: target
            )
            let response = scenario.response

            return Endpoint(
                url: endpoint.url,
                sampleResponseClosure: {
                    .networkResponse(response.statusCode, response.data)
                },
                method: endpoint.method,
                task: endpoint.task,
                httpHeaderFields: endpoint.httpHeaderFields
            )
        }

        return MoyaProvider<AuthTarget>(
            endpointClosure: endpointClosure,
            stubClosure: MoyaProvider.immediatelyStub
        )
    }
}
