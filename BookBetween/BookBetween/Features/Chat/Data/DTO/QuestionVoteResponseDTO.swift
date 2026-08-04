//
//  QuestionVoteResponseDTO.swift
//  BookBetween
//
//  Created by 한지민 on 8/1/26.
//

struct QuestionVoteResultDTO: Decodable {
  let currentVotes: Int
  let requiredVotes: Int
  let triggered: Bool
}

extension QuestionVoteResultDTO {
  func toDomain() -> QuestionVoteResult {
    QuestionVoteResult(
      currentVotes: currentVotes,
      requiredVotes: requiredVotes,
      triggered: triggered
    )
  }
}
