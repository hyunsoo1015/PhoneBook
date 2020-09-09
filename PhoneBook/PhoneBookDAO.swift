import Foundation
import UIKit

class PhoneBookDAO {
    //DTO 생성
    typealias PhoneRecord = (Int, String, String, String)
    
    //지연 생성(클라이언트에서 주로 이용)을 이용한 데이터베이스 연결
    //처음에는 존재하지 않다가 처음 사용할 때
    //구문을 수행해서 생성
    lazy var fmdb: FMDatabase! = {
        //데이터베이스 파일 경로 가져오기
        let fileMgr = FileManager.default
        let docPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docDir = docPaths[0] as String
        let dbPath = docDir.appending("/phonebook.sqlite")
        
        //데이터베이스 연결
        let db = FMDatabase(path: dbPath)
        
        return db
    }()
    
    //서버 프로그래밍에서는 하나의 요청이 오면 데이터베이스를 열고 작업을 수행한 후 닫는다.
    //이 작업을 직접 하지 않고 Connection Pool을 이용해서 수행
    
    //클라이언트 프로그래밍에서는 이럴 필요가 없다.
    //시작할 때 연결하고 종료할 때 닫는 방식을 이용한다.
    //초기화 메소드 - 생성자
    init() {
        //데이터베이스 열기
        self.fmdb.open()
    }
    
    //소멸자
    deinit {
        self.fmdb.close()
    }
    
    //전체 데이터 가져오는 메소드
    //매개변수가 없고 데이터의 모임을 리턴
    func find() -> [PhoneRecord] {
        //결과를 저장할 List를 생성
        //출력하는 곳에서는 반복문을 수행하기 때문에
        //nil이 리턴되면 안된다.
        var phoneList = [PhoneRecord]()
        
        //1. SQL 생성
        let sql = "select num,name,phone,addr from phonebook order by num asc"
        
        //2. 실행
        let rs = try! self.fmdb.executeQuery(sql, values: nil)
        
        //3. 결과 사용
        while rs.next() {
            let num = rs.int(forColumn: "num")
            let name = rs.string(forColumn: "name")
            let phone = rs.string(forColumn: "phone")
            let addr = rs.string(forColumn: "addr")
            
            phoneList.append((Int(num), name!, phone!, addr!))
        }
        
        //결과 리턴
        return phoneList
    }
    
    //num을 받아서 하나의 데이터를 리턴하는 메소드 - 상세보기
    func get(num:Int) -> PhoneRecord? {
        //1.sql 생성
        let sql = "select num, name, phone, addr from phonebook where num = ?"
        //2.SQL 실행
        let rs = self.fmdb.executeQuery(sql, withArgumentsIn:[num])
        //3.결과가 있는지 확인
        if let _rs = rs {
            _rs.next()
            let num = _rs.int(forColumn: "num")
            let name = _rs.string(forColumn: "name")
            let phone = _rs.string(forColumn: "phone")
            let addr = _rs.string(forColumn: "addr")
            return (Int(num), name!, phone!, addr!)
        } else {
            return nil
        }
    }
    
    //데이터를 삽입하는 메소드
    func create(name: String!, phone: String!, addr: String!) -> Bool {
        
        do {
            //sql 생성
            let sql = "insert into phonebook(name, phone, addr) values(?,?,?)"
            //SQL 실행
            try self.fmdb.executeUpdate(sql, values: [name!, phone!, addr!])
            return true
        } catch let error as NSError {
            NSLog(error.localizedDescription)
            return false
        }
        
    }
    
    //데이터를 삭제하는 메소드
    func delete(num: Int) -> Bool {
        
        do {
            //sql 생성
            let sql = "delete from phonebook where num=?"
            //SQL 실행
            try self.fmdb.executeUpdate(sql, values: [num])
            return true
        } catch let error as NSError {
            NSLog(error.localizedDescription)
            return false
        }
        
    }
    
}
