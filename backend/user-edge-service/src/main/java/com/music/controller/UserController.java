package com.music.controller;

import com.music.domain.UserInfo;
import com.music.domain.UserStyleInfo;
import com.music.redis.RedisClient;
import com.music.service.UserService;
import com.music.thrift.ServiceProvider;
import com.music.thrift.message.MessageService;
import com.music.util.messagedigest.MD;
import com.music.util.randoncode.RC;
import com.music.util.response.LoginResponse;
import com.music.util.response.Response;
import com.music.util.token.Token;
import org.apache.commons.lang.StringUtils;
import org.apache.thrift.TException;
import org.apache.thrift.TServiceClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Repository;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;

@Controller
@RequestMapping("/user")
public class UserController {

    @Resource
    private ServiceProvider serviceProvider;

    @Resource
    private RedisClient redisClient;

    @Resource
    private UserService userService;

    @RequestMapping(value = "/login", method = RequestMethod.GET)
    public String login(){
        return "login";
    }

    /**
     * 登录功能
     * @param username
     * @param password
     * @return
     */
    @RequestMapping(value = "/login", method = RequestMethod.POST)
    @ResponseBody
    public Response login(@RequestParam("username") String username, @RequestParam("password") String password){
        UserInfo userInfo = userService.getUserByName(username);
        if (userInfo == null){
            return Response.USERNAME_PASSWORD_INVALID;
        }
        if (!userInfo.getPassword().equalsIgnoreCase(MD.md5(password))){
            return Response.USERNAME_PASSWORD_INVALID;
        }

        String token = Token.genToken();
        redisClient.set(token, userInfo, 3000);

        return new LoginResponse(token);
    }

    /**
     * 发送验证码
     * @param email
     * @return
     */
    @RequestMapping(value = "/sendVerifyCode", method = RequestMethod.POST)
    @ResponseBody
    public Response sendVerifyCode(@RequestParam("email") String email){

        String message = "VerifyCode is : ";
        String code = RC.randomCode("0123456789", 6);
        MessageService.Iface messageService = serviceProvider.getMessageService();
        boolean result = false;
        try {

            result = messageService.sendEmailMessage(email, message + code);
            redisClient.set(email, code);

            if (!result){
                return Response.SEND_VERIFYCODE_FAILED;
            }
        }catch (TException e){
            e.printStackTrace();
            return Response.exception(e);
        }

        return null;

    }

    /**
     * 注册功能
     */
    @RequestMapping(value = "/register", method = RequestMethod.POST)
    @ResponseBody
    public Response register(@RequestParam("username") String username,
                             @RequestParam("password") String password,
                             @RequestParam("email") String email,
                             @RequestParam("age") int age,
                             @RequestParam("gender") int gender,
                             @RequestParam("location") String location,
                             @RequestParam("style") List<Integer> style,
                             @RequestParam("verifyCode") String verifyCode){

        UserInfo userInfoGot = userService.getUserByName(username);
        if (userInfoGot != null){
            return Response.USERNAME_EXIST;
        }

        String redisCode = redisClient.get(email);
        if (!verifyCode.equals(redisCode)){
            return Response.VERIFY_CODE_INVALID;
        }

        UserInfo userInfo = new UserInfo();
        userInfo.setUsername(username);
        userInfo.setPassword(MD.md5(password));
        userInfo.setEmail(email);
        userInfo.setAge(age);
        userInfo.setGender(gender);
        userInfo.setLocation(location);

        userService.registerUser(userInfo);

        userInfoGot = userService.getUserByName(username);
        UserStyleInfo userStyleInfo = new UserStyleInfo();
        userStyleInfo.setUid(userInfoGot.getId());
        for (Integer i : style){
            userStyleInfo.setSid(i);
            userService.setUserStyle(userStyleInfo);
        }

        return Response.SUCCESS;

    }

    /**
     * 验证是否已经登录
     */
    @RequestMapping(value = "/authentication", method = RequestMethod.POST)
    @ResponseBody
    public UserInfo authentication(@RequestParam("token") String token){
        return redisClient.get(token);
    }

}