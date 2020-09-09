import UIKit

class PhoneListVC: UITableViewController {
    //데이터 목록을 저장할 변수
    var phoneBook: [(num: Int, name: String, phone: String, addr: String)]!
    //DAO 변수
    let dao = PhoneBookDAO()

    override func viewDidLoad() {
        super.viewDidLoad()

        //전체 데이터 가져오기
        phoneBook = self.dao.find()
        //네비게이션 바에 레이블 출력
        //새로 생성해서 추가
        let navTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        navTitle.numberOfLines = 2
        navTitle.textAlignment = .center
        navTitle.text = "연락처 목록 \n" + "총 \(self.phoneBook.count) 개"
        self.navigationItem.titleView = navTitle
        
        //네비게이션 바의 오른쪽 바 버튼 아이템 추가
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add(_:)))
        
        //왼쪽에 편집 버튼 배치
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.tableView.allowsSelectionDuringEditing = true
    }
    
    //바 버튼 아이템이 호출할 메소드
    @objc func add(_ sender: Any) {
        //대화상자 만들기
        let alert = UIAlertController(title: "데이터 삽입", message: "연락처 등록", preferredStyle: .alert)
        
        //입력 필드 만들기
        alert.addTextField(){(tf) in tf.placeholder = "이름"}
        alert.addTextField(){(tf) in tf.placeholder = "전화번호"}
        alert.addTextField(){(tf) in tf.placeholder = "주소"}
        
        //버튼 만들기
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .default){(_) in
            //입력한 내용 가져오기
            let name = alert.textFields?[0].text
            let phone = alert.textFields?[1].text
            let addr = alert.textFields?[2].text
            
            //테이블에 삽입
            self.dao.create(name: name, phone: phone, addr: addr)
            //데이터를 다시 가져와서 재출력
            self.phoneBook = self.dao.find()
            self.tableView.reloadData()
            
            //레이블도 다시 출력
            let naviTitle = self.navigationItem.titleView as! UILabel
            naviTitle.text = "연락처 목록\n" + "총\(self.phoneBook.count) 개"
        })
        
        //대화상자 출력
        self.present(alert, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phoneBook.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //출력할 데이터 찾아오기
        let rowData = phoneBook[indexPath.row]
        
        //셀을 생성
        let cellIdentifier = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        cell!.textLabel!.text = rowData.name
        cell!.detailTextLabel!.text = "\(rowData.phone) \(rowData.addr)"
        return cell!
    }
    
    //edit 버튼을 눌렀을 때 보여질 버튼 설정 메소드
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    //실제 삭제를 눌렀을 때 호출되는 메소드
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let num = self.phoneBook[indexPath.row].num
        
        dao.delete(num: num)
        //삭제하는 애니메이션을 적용
        self.phoneBook.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }

}
