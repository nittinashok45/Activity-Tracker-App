import CoreData
import Foundation

class Userinfomanage: ObservableObject {
    private let container: NSPersistentContainer
    private var context: NSManagedObjectContext { container.viewContext }
    

    
    @Published var userInfos: [UserInfo] = []
    
    init() {
        container = NSPersistentContainer(name: "NittinCSE335Phase2")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        loadUserInfos()
    }
    
    private func loadUserInfos() {
        let fetchRequest: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
        do {
            userInfos = try context.fetch(fetchRequest)
        } catch {
            print("Error loading UserInfo: \(error)")
        }
    }
    


    
    func addUserInfo(startDate: Date, startTime: Date, endTime: Date, city: String, importantPlace: String, activityInfo: String, activityType: String) {
            let calendar = Calendar.current
            let dateOnly = calendar.startOfDay(for: startDate)
            let timeOnlyStart = calendar.dateComponents([.hour, .minute], from: startTime)
            let timeOnlyEnd = calendar.dateComponents([.hour, .minute], from: endTime)

            let newStartTime = calendar.date(from: timeOnlyStart)
            let newEndTime = calendar.date(from: timeOnlyEnd)

            let fetchRequest: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "startdate == %@ AND starttime == %@", dateOnly as NSDate, newStartTime! as NSDate)
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.isEmpty {
                    let newUserInfo = UserInfo(context: context)
                    newUserInfo.startdate = dateOnly
                    newUserInfo.starttime = newStartTime
                    newUserInfo.endtime = newEndTime
                    newUserInfo.city = city
                    newUserInfo.importantplace = importantPlace
                    newUserInfo.activityinfo = activityInfo
                    newUserInfo.activitytype = activityType
                    try context.save()
                    loadUserInfos()
                } else {
                    print("A UserInfo entry with the same start date and time already exists.")
                }
            } catch {
                print("Error checking for duplicates or saving new UserInfo: \(error)")
            }
        }
        
        func updateUserInfo(startDate: Date, startTime: Date, newEndTime: Date?, newCity: String?, newImportantPlace: String?, newActivityInfo: String?, newActivityType: String?) {
            let calendar = Calendar.current
            let dateOnly = calendar.startOfDay(for: startDate)
            let timeOnlyStart = calendar.dateComponents([.hour, .minute], from: startTime)
            let newStartTime = calendar.date(from: timeOnlyStart)

            let fetchRequest: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "startdate == %@ AND starttime == %@", dateOnly as NSDate, newStartTime! as NSDate)

            do {
                let results = try context.fetch(fetchRequest)
                if let userInfoToUpdate = results.first {
                    print("Fetch results: \(results)")

                     
                    if let newEnd = newEndTime {
                        let timeOnlyEnd = calendar.dateComponents([.hour, .minute], from: newEnd)
                        userInfoToUpdate.endtime = calendar.date(from: timeOnlyEnd)
                    }
                    
                    userInfoToUpdate.city = newCity ?? userInfoToUpdate.city
                    userInfoToUpdate.importantplace = newImportantPlace ?? userInfoToUpdate.importantplace
                    userInfoToUpdate.activityinfo = newActivityInfo ?? userInfoToUpdate.activityinfo
                    userInfoToUpdate.activitytype = newActivityType ?? userInfoToUpdate.activitytype
                    try context.save()
                    loadUserInfos()
                } else {
                    print("No UserInfo found with the given startDate and startTime for update.")
                }
            } catch {
                print("Error updating UserInfo: \(error)")
                print("Error updating UserInfo: \(error)")
            }
        }
        
        func deleteUserInfo(startDate: Date, startTime: Date) {
            let calendar = Calendar.current
            let dateOnly = calendar.startOfDay(for: startDate)
            let timeOnlyStart = calendar.dateComponents([.hour, .minute], from: startTime)
            let newStartTime = calendar.date(from: timeOnlyStart)

            let fetchRequest: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "startdate == %@ AND starttime == %@", dateOnly as NSDate, newStartTime! as NSDate)

            do {
                let results = try context.fetch(fetchRequest)
                if let userInfoToDelete = results.first {
                    context.delete(userInfoToDelete)
                    try context.save()
                    loadUserInfos()
                } else {
                    print("No UserInfo found with the given startDate and startTime for deletion.")
                }
            } catch {
                print("Error deleting UserInfo: \(error)")
            }
        }
    
    

    
    func deleteAllUserInfos() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserInfo.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            loadUserInfos()
        } catch {
            print("Error deleting all UserInfo records: \(error)")
        }
    }
    
    
    
    
    func loadActivities(for date: Date) {
        let request: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "startdate >= %@", startDate as NSDate),
            NSPredicate(format: "startdate < %@", endDate as NSDate)
        ])
        
        do {
            userInfos = try context.fetch(request)
        } catch {
            print("Error fetching activities for the date: \(error)")
        }
    }

    func isDuplicate(startDate: Date, startTime: Date) -> Bool {
        let calendar = Calendar.current
        let dateOnly = calendar.startOfDay(for: startDate)
        let timeOnlyStart = calendar.dateComponents([.hour, .minute], from: startTime)
        let newStartTime = calendar.date(from: timeOnlyStart)

        let fetchRequest: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "startdate == %@ AND starttime == %@", dateOnly as NSDate, newStartTime! as  NSDate)

        do {
            let results = try context.fetch(fetchRequest)
            return !results.isEmpty
        } catch {
            print("Error checking for duplicates: \(error)")
            return false
        }
    }

        func isValidForUpdate(startDate: Date, startTime: Date) -> Bool {
            return isDuplicate(startDate: startDate, startTime: startTime)
        }

        func isValidForDelete(startDate: Date, startTime: Date) -> Bool {
            return isDuplicate(startDate: startDate, startTime: startTime)
        }
        
}

