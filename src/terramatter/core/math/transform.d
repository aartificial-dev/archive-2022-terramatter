module terramatter.core.math.transform;

import terramatter.core.math.matrix;
import terramatter.core.math.vector;

class Transform {
    private Matrix4f _translationMat;
    private Matrix4f _scaleMat;
    private Matrix4f _rotationMat;
    
    private Matrix4f _transformMat;

    this() {
        _translationMat = new Matrix4f().initTranslation(0, 0, 0);
        _scaleMat = new Matrix4f().initScale(1, 1, 1);
        _rotationMat = new Matrix4f().initRotation(0, 0, 0);
        _transformMat = _translationMat * _scaleMat * _rotationMat;
    }

    public void setParent(Transform tr) {

    }

    public void update() {
        _transformMat = _translationMat * _scaleMat * _rotationMat;
    }

    // TODO
    // LINK https://learnopengl.com/Getting-started/Transformations
}