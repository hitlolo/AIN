//
//  AINURLHttp.h
//  AIN
//
//  Created by Lolo on 16/6/2.
//  Copyright © 2016年 Lolo. All rights reserved.
//


#ifndef AINURLHttp_h
#define AINURLHttp_h

static NSString* const carousel_url = @"http://v3.wufazhuce.com:8000/api/reading/carousel";
static NSString* const carousel_item_url = @"http://v3.wufazhuce.com:8000/api/reading/carousel/%@";
//gallery
static NSString* const gallery_url = @"http://v3.wufazhuce.com:8000/api/hp/more/%@";
static NSString* const gallery_url_bymonth = @"http://v3.wufazhuce.com:8000/api/hp/bymonth/%@";
static NSString* const gallery_url_search = @"http://v3.wufazhuce.com:8000/api/search/hp/%@";

//reading
static NSString* const reading_index = @"http://v3.wufazhuce.com:8000/api/reading/index";
static NSString* const reading_essay = @"http://v3.wufazhuce.com:8000/api/essay/%@";
static NSString* const reading_serial = @"http://v3.wufazhuce.com:8000/api/serialcontent/%@";
static NSString* const reading_question = @"http://v3.wufazhuce.com:8000/api/question/%@";

//comments
static NSString* const reading_comment = @"http://v3.wufazhuce.com:8000/api/comment/praiseandtime/%@/%@/%@";

//related
static NSString* const reading_related = @"http://v3.wufazhuce.com:8000/api/related/%@/%@";

//by month
static NSString* const reading_essay_bymonth = @"http://v3.wufazhuce.com:8000/api/essay/bymonth/%@";
static NSString* const reading_serial_bymonth = @"http://v3.wufazhuce.com:8000/api/serial/bymonth/%@";
static NSString* const reading_question_bymonth = @"http://v3.wufazhuce.com:8000/api/question/bymonth/%@";

static NSString* const reading_article_bymonth = @"http://v3.wufazhuce.com:8000/api/%@/bymonth/%@";

static NSString* const reading_serial_contents = @"http://v3.wufazhuce.com:8000/api/serial/list/%@";


//elephant

static NSString* const elephant_index_url = @"http://app.idaxiang.org/api/v1_0/art/list?pageSize=20";
static NSString* const elephant_more_url = @"http://app.idaxiang.org/api/v1_0/art/list?pageSize=20&create_time=%@&update_time=%@";
static NSString* const elephant_url =@"http://app.idaxiang.org/api/v1_0/art/info?id=%@";


//movie

static NSString* const movie_index = @"http://v3.wufazhuce.com:8000/api/movie/list/%@";
static NSString* const movie_detail = @"http://v3.wufazhuce.com:8000/api/movie/detail/%@";
#endif /* AINURLHttp_h */
