package com.slms.dao;

import com.slms.dto.ChatMessageDTO;
import com.slms.dto.UserDTO;
import java.sql.SQLException;
import java.util.List;

public interface ChatDAO {
    void save(ChatMessageDTO message) throws SQLException;
    List<ChatMessageDTO> findConversation(int userId1, int userId2) throws SQLException;
    List<UserDTO> findConversationPartners(int userId) throws SQLException;
    void markAsRead(int senderId, int receiverId) throws SQLException;
    int countUnread(int receiverId) throws SQLException;
}
