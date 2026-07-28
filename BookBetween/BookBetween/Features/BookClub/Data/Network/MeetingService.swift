import Foundation
import Moya

protocol MeetingServiceProtocol {
    func fetchMeetingDetail(meetingId: Int) async throws -> BookMeeting
    func participateMeeting(meetingId: Int) async throws -> Int
    func searchMeetings(name: String, page: Int, size: Int) async throws -> [BookMeeting]
    func createMeeting(isbn: String, startDate: String, startTime: String, maxParticipants: Int, duration: Int) async throws -> Int
    func fetchMyMeetings(isLeader: Bool, year: Int?, month: Int?, page: Int, size: Int) async throws -> [BookMeeting]
}

final class MeetingService: MeetingServiceProtocol {
    private let baseURL: URL
    private let provider: MoyaProvider<MeetingTarget>
    private let requestExecutor: AuthenticatedRequestExecutor

    init(configuration: NetworkConfiguration) {
        self.baseURL = configuration.baseURL
        self.provider = MoyaProvider<MeetingTarget>(
            plugins: [
                AuthorizationPlugin(accessToken: configuration.accessToken)
            ]
        )
        self.requestExecutor = AuthenticatedRequestExecutor(
            reissueTokens: configuration.reissueTokens
        )
    }

    init(baseURL: URL, provider: MoyaProvider<MeetingTarget>) {
        self.baseURL = baseURL
        self.provider = provider
        self.requestExecutor = AuthenticatedRequestExecutor(
            reissueTokens: nil
        )
    }

    func fetchMeetingDetail(meetingId: Int) async throws -> BookMeeting {
        try await requestExecutor.execute {
            do {
                let response = try await provider.requestAsync(
                    MeetingTarget(
                        baseURL: baseURL,
                        endpoint: .getMeetingDetail(meetingId: meetingId)
                    )
                )
                let result = try response.decodePayload(MeetingResultDTO.self)
                return try result.toDomain()
            } catch let error as MoyaError {
                throw NetworkError.transport(error)
            }
        }
    }

    func participateMeeting(meetingId: Int) async throws -> Int {
        do {
            let response = try await provider.requestAsync(
                MeetingTarget(baseURL: baseURL, endpoint: .participateMeeting(meetingId: meetingId))
            )
            let result = try response.decodePayload(MeetingParticipationResultDTO.self)
            return result.meetingParticipantId
        } catch let error as MoyaError {
            throw NetworkError.transport(error)
        }
    }

    func searchMeetings(name: String, page: Int, size: Int) async throws -> [BookMeeting] {
        do {
            let response = try await provider.requestAsync(
                MeetingTarget(baseURL: baseURL, endpoint: .searchMeetings(name: name, page: page, size: size))
            )
            let result = try response.decodePayload(MeetingListResultDTO.self)
            return result.toDomain()
        } catch let error as MoyaError {
            throw NetworkError.transport(error)
        }
    }

    func fetchMyMeetings(isLeader: Bool, year: Int?, month: Int?, page: Int, size: Int) async throws -> [BookMeeting] {
        do {
            let response = try await provider.requestAsync(
                MeetingTarget(baseURL: baseURL, endpoint: .fetchMyMeetings(isLeader: isLeader, year: year, month: month, page: page, size: size))
            )
            let result = try response.decodePayload(MeetingListResultDTO.self)
            return result.toDomain()
        } catch let error as MoyaError {
            throw NetworkError.transport(error)
        }
    }

    func createMeeting(isbn: String, startDate: String, startTime: String, maxParticipants: Int, duration: Int) async throws -> Int {
        let body = MeetingCreateRequestBody(
            isbn: isbn,
            startDate: startDate,
            startTime: startTime,
            maxParticipants: maxParticipants,
            duration: duration
        )
        do {
            let response = try await provider.requestAsync(
                MeetingTarget(baseURL: baseURL, endpoint: .createMeeting(body: body))
            )
            let result = try response.decodePayload(MeetingCreateResultDTO.self)
            return result.id
        } catch let error as MoyaError {
            throw NetworkError.transport(error)
        }
    }
}
