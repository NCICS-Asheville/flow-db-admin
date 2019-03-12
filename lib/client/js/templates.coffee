Template.AdminDashboardView.rendered = ->
    table = @$('.dataTable').DataTable();

Template.AdminDashboardView.helpers
    hasDocuments: ->
        AdminCollectionsCount.findOne({collection: Session.get 'admin_collection_name'})?.count > 0
    newPath: ->
        FlowRouter.path "/admin/new/:coll",{coll: Session.get 'admin_collection_name' }
    admin_table: ->
        AdminTables[Session.get 'admin_collection_name']

Template.adminUsersIsAdmin.helpers checkadmin: ->
    Roles.userIsInRole @_id, 'admin'

Template.adminUsersMailBtn.helpers adminUserEmail: ->
    user = @
    if user && user.emails && user.emails[0] && user.emails[0].address
        user.emails[0].address
    else if user && user.services && user.services.facebook && user.services.facebook.email
        user.services.facebook.email
    else if user && user.services && user.services.google && user.services.google.email
        user.services.google.email
    else 'null@null.null'

Template.adminEditBtn.helpers path: ->
  FlowRouter.path '/admin/edit/:coll/:_id',
    coll: Session.get('admin_collection_name')
    _id: @_id

Template.adminDeleteBtn.helpers path: ->
  FlowRouter.path '/admin/edit/:coll/:_id', {
    coll: Session.get('admin_collection_name')
    _id: @_id
  }, action: 'delete'

Template.AdminHeader.helpers
    profilepath: -> FlowRouter.path '/admin/edit/:coll/:_id',
      coll: 'Users'
      _id: Meteor.userId()

Template.AdminDashboardEdit.rendered = ->
    editcollectionName = FlowRouter.getParam 'collectionName'
    editId    = FlowRouter.getParam '_id'
    Session.set 'admin_doc', adminCollectionObject(editcollectionName).findOne _id : editId

Template.AdminDashboardEdit.helpers
    fadmin_doc: ->
      editcollectionName = FlowRouter.getParam 'collectionName'
      editId    = FlowRouter.getParam '_id'
      adminCollectionObject(editcollectionName).findOne _id : editId if editcollectionName && editId
  action: -> FlowRouter.getQueryParam 'action'


Template.AdminDashboardUsersEdit.rendered = ->
  editcollectionName = FlowRouter.getParam 'collectionName'
  editId    = FlowRouter.getParam '_id'
  console.log 'here', adminCollectionObject(editcollectionName).findOne _id : editId
  Session.set 'admin_doc', adminCollectionObject(editcollectionName).findOne _id : editId

Template.AdminDashboardUsersEdit.helpers
  user: -> Meteor.users.find(FlowRouter.getParam '_id').fetch()
  action: -> FlowRouter.getQueryParam 'action'
  groups: ->
     Meteor.subscribe('projects') 
     _.map adminCollectionObject('Projects').find({}).fetch(), (project) -> project.identifier
  #Roles.getGroupsForUser(FlowRouter.getParam '_id')
  roles: (group) -> 
    user = Meteor.users.findOne(FlowRouter.getParam '_id')
    if group
      roles = user.roles[group]
      #roles = _.difference(Roles.getRolesForUser(FlowRouter.getParam('_id'), group.toString()), Roles.getRolesForUser(FlowRouter.getParam '_id'))
    else
      roles = Roles.getRolesForUser(FlowRouter.getParam '_id')
  otherRoles: (group) ->
    user = Meteor.users.findOne(FlowRouter.getParam '_id')
    if (group)
      if (user && user.roles && user.roles[group]) 
        _.difference _.map(Meteor.roles.find().fetch(), (role) -> role.name), user.roles[group] #Roles.getRolesForUser(FlowRouter.getParam('_id'), group)
      else
        _.map(Meteor.roles.find().fetch(), (role) -> role.name)
    else
      _.difference _.map(Meteor.roles.find().fetch(), (role) -> role.name), Roles.getRolesForUser(FlowRouter.getParam '_id')
