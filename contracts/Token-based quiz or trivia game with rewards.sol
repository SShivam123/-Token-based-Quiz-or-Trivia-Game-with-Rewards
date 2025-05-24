// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenQuizGame is Ownable {
    IERC20 public rewardToken;
    uint256 public questionCount;
    uint256 public rewardAmount;

    struct Question {
        string questionText;
        string[] options;
        uint8 correctOption; // index of correct option
        bool exists;
    }

    mapping(uint256 => Question) public questions;
    mapping(address => uint256) public rewardsEarned;

    event QuestionAdded(uint256 indexed questionId);
    event Answered(address indexed player, uint256 indexed questionId, bool correct, uint256 reward);
    event RewardWithdrawn(address indexed player, uint256 amount);

    constructor() Ownable(msg.sender) {
        // Default token address (replace with actual reward token address in production)
        rewardToken = IERC20(0x000000000000000000000000000000000000dEaD);
        rewardAmount = 100 * 10 ** 18; // Default: 100 tokens with 18 decimals
    }

    function addQuestion(
        string calldata _questionText,
        string[] calldata _options,
        uint8 _correctOption
    ) external onlyOwner {
        require(_correctOption < _options.length, "Invalid correct option index");
        questionCount++;
        questions[questionCount] = Question({
            questionText: _questionText,
            options: _options,
            correctOption: _correctOption,
            exists: true
        });
        emit QuestionAdded(questionCount);
    }

    function answerQuestion(uint256 _questionId, uint8 _selectedOption) external {
        Question storage question = questions[_questionId];
        require(question.exists, "Question does not exist");
        require(_selectedOption < question.options.length, "Invalid option selected");
        
        bool isCorrect = (_selectedOption == question.correctOption);
        uint256 reward = 0;
        
        if (isCorrect) {
            rewardsEarned[msg.sender] += rewardAmount;
            reward = rewardAmount;
        }
        
        emit Answered(msg.sender, _questionId, isCorrect, reward);
    }

    function withdrawRewards() external {
        uint256 amount = rewardsEarned[msg.sender];
        require(amount > 0, "No rewards to withdraw");
        
        rewardsEarned[msg.sender] = 0;
        require(rewardToken.transfer(msg.sender, amount), "Token transfer failed");
        
        emit RewardWithdrawn(msg.sender, amount);
    }

    function fundContract(uint256 amount) external onlyOwner {
        require(rewardToken.transferFrom(msg.sender, address(this), amount), "Funding failed");
    }
}
