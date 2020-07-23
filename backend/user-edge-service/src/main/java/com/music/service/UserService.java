package com.music.service;

import com.music.domain.UserInfo;
import org.springframework.stereotype.Service;

/**
 * 用户的业务层接口
 */
public interface UserService {
    UserInfo getUserByName(String username);
    void registerUser(UserInfo userInfo);
}
